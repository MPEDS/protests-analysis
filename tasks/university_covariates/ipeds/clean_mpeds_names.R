# Matches GLUED, IPEDS and MPEDS names together
# Going to be tough -- the names MPEDS uses and the names GLUED/IPEDS uses
# don't follow the same conventions.
# I'd even say (after perusing the codebook) that the MPEDS
# names do not follow any predetermined convention

# So this will work in a two-stage pass: first we'll do some basic matches/rules
# to see what MPEDS names have an IPEDS/GLUED counterpart -- which I refer to as
# `authoritative`, and export the remainder
# (e.g. unmatched) to a local CSV. The second pass will involve manually
# writing down corresponding IPEDS/GLUED names for each unmatched MPEDS name.

#' First pass function- helps dedupe/correct names in MPEDS
#' @param cleaned_events Canonical events otherwise post-processing
#' @param ipeds the IPEDS initial import
#' @param glued the initial GLUED import
clean_mpeds_names <- function(cleaned_events, ipeds, glued){
  authoritative_uni_directory <- bind_rows(
    list(
      ipeds = ipeds |>
        group_by(uni_id) |>
        arrange(desc(year)) |>
        slice_head(n = 1) |>
        select(authoritative_uni_id = uni_id, uni_name),
      glued = glued |>
        group_by(uni_id) |>
        arrange(desc(year)) |>
        select(authoritative_uni_id = uni_id, uni_name) |>
        slice_head(n = 1)
    ),
    .id = "data_source"
  )

  authoritative_uni_matcher <- authoritative_uni_directory |>
    mutate(is_authoritative = TRUE) |>
    distinct()

  mpeds_names <- cleaned_events |>
    pull(university) |>
    bind_rows() |>
    distinct() |>
    arrange(university_name) |>
    mutate(name = university_name, og_name = university_name,
           uni_id = "", uni_data_source = "") |>
    select(-university_name)

  # If adding a dash between the last two words helps,
  # add the dash, otherwise keep old name
  # E.g. IPEDS has "University of Missouri-Columbia" but MPEDS has
  # "University of Missouri Columbia
  # Repeat for adding "University", "College", "-Main Campus", and
  # "School" at the end of words
  # These follow more or less the same pattern, so I'll do it functionally,
  # but ... this is getting out of hand
  # Wish R had a more concise object creation term
  patterns <- list(
    list(pattern = "('s)?(\\s)?(c|C)ampus", repl = ""),
    # Try to replace whitespace(s) with "-"
    list(pattern = "\\s(?!\\S*\\s)", repl = "-"),
    list(repl = " University"),
    list(repl = " College"),
    list(repl = "-Main Campus"),
    list(repl = " School")
  )

  raw_coarse_filename <- "tasks/university_covariates/hand/raw_uni_match.csv"
  reduce(patterns, function(mpeds_iteration, matcher){
    mpeds_iteration |>
      mutate(alt_name = str_replace(
          name,
          # if `pattern` isn't given, append `repl` to the end of a word
          ifelse(is.null(matcher$pattern), "$", matcher$pattern),
          matcher$repl)) |>
      left_join(authoritative_uni_matcher, by = c("alt_name" = "uni_name"),
                multiple = "all", relationship = "many-to-many") |>
      mutate(
        # if is_authoritative is TRUE, then the new rule helped find a match
        # case_when() needed since ipeds_dummy is TRUE or NA, not TRUE or FALSE
        name = case_when(
          is_authoritative ~ alt_name,
          TRUE ~ name
        ),
        uni_id = case_when(
          is_authoritative ~ authoritative_uni_id,
          TRUE ~ uni_id,
        ),
        uni_data_source = case_when(
          is_authoritative ~ data_source,
          TRUE ~ uni_data_source
        )) |>
      select(-is_authoritative, -alt_name, -authoritative_uni_id, -data_source)
  }, .init = mpeds_names) |>
    # final match to know which are correct and which need adjustments
    left_join(authoritative_uni_matcher, by = c("name" = "uni_name"),
              multiple = "all", relationship = "many-to-many") |>
    mutate(is_authoritative = case_when(
      is_authoritative == TRUE ~ TRUE,
      TRUE ~ FALSE
      )) |>
    arrange(is_authoritative) |>
    select(original_name = og_name,
           authoritative_name = name,
           uni_id, uni_data_source) |>
    # Since often names in our data like "Columbia" get matched
    # to multiple universities, and that is a task for coders to correct
    # and cannot be resolved programmatically, and it is confusing to include
    # single entries more than once, i am arbitrarily selecting one name
    group_by(original_name) |>
    slice_head(n = 1) |>
    distinct() |>
    write_csv(raw_coarse_filename)

  return(raw_coarse_filename)
}

#' updates to the matching method or underlying data will create
#' changes to the raw coarse match file that have to be propagated
#' to the cleaned coarse match file. For the first pass (catching the majority)
#' that was done manually by me;
#' This function propagates changes so that the undergrad RAs can catch
#' future changes
update_coarse_matches <- function(raw_coarse_filename){
  raw_coarse <- read_csv(raw_coarse_filename, show_col_types = FALSE)
  coarse_filename <- "tasks/university_covariates/hand/coarse_uni_match.csv"
  cleaned_coarse <- read_csv(coarse_filename, show_col_types = FALSE)  |>
    # In case `raw_coarse` has updated names, for example from a refreshed
    # DB pipeline run, add them here to the ones I manually corrected
    # Not joining on uni_id, although that is needed to ambiguously identify
    # the names, since `raw_coarse` may have it missing
    full_join(raw_coarse, by = "original_name",
              multiple = "all"
              ) |>
    mutate(
      authoritative_name.x = ifelse(!is.na(authoritative_name.x),
                                    authoritative_name.x,
                                    authoritative_name.y),
      uni_id.x = ifelse(!is.na(uni_id.x), uni_id.x, uni_id.y),
      uni_data_source.x = ifelse(!is.na(uni_data_source.x),
                                 uni_data_source.x, uni_data_source.y),
    ) |>
    select(
      original_name,
      authoritative_name = authoritative_name.x,
      canada,
      uni_id = uni_id.x,
      uni_data_source = uni_data_source.x
    ) |>
    distinct()

  write_csv(cleaned_coarse, coarse_filename)
  return(coarse_filename)
}


#' After the coarse clean by name only, add in canonical event keys and
#' format the match spreadsheet so coders can clean it easily
postprocess_names <- function(cleaned_events, coarse_uni_match_filename, intermediate_pass_filename,
                              glued_raw, ipeds_raw,
                              canonical_event_relationship, canada_geo){
  coarse_uni_match <- read_csv(coarse_uni_match_filename, show_col_types = FALSE)
  # The coders can make multiple passes as we revise the process;
  # this integrates their changes into the new dataset produced
  intermediate_pass <- read_csv(intermediate_pass_filename, show_col_types = FALSE) |>
    filter(seen) |>
    select(seen, original_name, canonical_event_key,
           true_uni_id = uni_id, true_uni_data_source = uni_data_source,
           true_name = authoritative_name) |>
    distinct()

  # Creating a keys dataframe so that coders can reference canonical event keys
  # for names
  keys <- cleaned_events |>
    select(key, university, description) |>
    unnest(university) |>
    select(-lat, -lng)

  postprocess_filename <- "tasks/university_covariates/hand/university_names_verification.xlsx"
  umbrella_ids <- canonical_event_relationship |>
    filter(relationship_type == "campaign") |>
    pull(canonical_id2) |>
    unique()
  umbrella_keys <- cleaned_events |>
    filter(canonical_id %in% umbrella_ids) |>
    pull(key) |>
    unique()

  coarse_uni_match <- coarse_uni_match |>
    mutate(authoritative_name = ifelse(
      !is.na(authoritative_name),
      authoritative_name,
      original_name
      ),
      original_name = str_remove_all(original_name, ",") |> str_trim()) |>
    distinct()

  MPEDS <- keys |>
    rename(original_name = university_name) |>
    # Multiple=first is fine because we don't want RAs to check same university-key twice
    left_join(coarse_uni_match, by = "original_name", multiple = "first") |>
    filter(!is.na(original_name),
           !is.na(key),
           !(key %in% umbrella_keys)) |>
    select(original_name, original_source = uni_name_source,
           authoritative_name, authoritative_id = uni_id,
           authoritative_source = uni_data_source,
           canonical_event_key = key, description) |>
    left_join(intermediate_pass, by = c("original_name", "canonical_event_key"),
              multiple = "first") |>
    mutate(
      authoritative_id = ifelse(!is.na(true_uni_id), true_uni_id, authoritative_id),
      authoritative_name = ifelse(!is.na(true_name), true_name, authoritative_name),
      authoritative_source = ifelse(!is.na(true_uni_data_source), true_uni_data_source, authoritative_source),
      notes = "",
      authoritative_name = ifelse(is.na(authoritative_id), NA, authoritative_name)) |>
    select(-true_uni_data_source, -true_uni_id, -true_name) |>
    select(seen, everything()) |>
    arrange(seen, canonical_event_key)

  ipeds <- ipeds_raw |>
    group_by(UNITID) |>
    slice_max(order_by = year, n = 1) |>
    select(id = UNITID, name = INSTNM, address = ADDR,
           city = CITY, state = STABBR)

  glued <- glued_raw |>
    filter(country == "canada") |>
    group_by(iau_id1) |>
    slice_max(order_by = year, n = 1) |>
    select(id = iau_id1, uni_name = eng_name, foundedyr, coordinates) |>
    separate(coordinates, sep = ", ", into = c("lat", "lon")) |>
    st_as_sf(coords = c("lon", "lat"), na.fail = FALSE) |>
    st_set_crs(st_crs(canada_geo)) |>
    st_join(canada_geo) |>
    select(-geoid) |>
    st_drop_geometry()

  writexl::write_xlsx(
    list(
      MPEDS = MPEDS,
      GLUED = glued,
      IPEDS = ipeds
    ),
    postprocess_filename
  )
  return(postprocess_filename)
}

#' Also exporting a tibble of only-Canada universities so that coders can
#' begin tracking down covariates
#' Notably this exports unclean, MPEDS-style university names, not authoritative
#' ones from GLUED
export_canada <- function(uni_xwalk_filename, glued){
  coarse_canada <- read_csv(uni_xwalk_filename, show_col_types = FALSE) |>
    filter(canada | uni_data_source == "glued") |>
    select(university_name = original_name)
  list(
    GLUED = glued,
    MPEDS = coarse_canada
  ) |>
    writexl::write_xlsx("tasks/university_covariates/hand/canadian_universities.xlsx")
}

