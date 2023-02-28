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
#' @param geocoded canonical events with geocoded names (the `geocoded` target)
#' @param ipeds the IPEDS initial import
#' @param glued the initial GLUED import
clean_mpeds_names <- function(geocoded, ipeds, glued){
  authoritative_uni_directory <- bind_rows(
    list(
      ipeds = ipeds |>
        group_by(id) |>
        arrange(desc(year)) |>
        slice_head(n = 1) |>
        select(id, uni_name),
      glued = glued |>
        group_by(glued_id) |>
        arrange(desc(year)) |>
        select(id = glued_id, uni_name) |>
        slice_head(n = 1)
    ),
    .id = "data_source"
  )

  authoritative_uni_matcher <- authoritative_uni_directory |>
    mutate(is_authoritative = TRUE) |>
    distinct()

  mpeds_names <- geocoded |>
    select(university, participating_universities) |>
    unnest(participating_universities, keep_empty = TRUE) |>
    unnest(university, keep_empty = TRUE) |>
    pivot_longer(cols = c(university, participating_universities),
                 values_to = "university"
                 ) |>
    select(-name) |>
    mutate(university = str_remove_all(university, ",") |> str_trim()) |>
    distinct() |>
    arrange(university) |>
    mutate(name = university, og_name = university,
           uni_id = "", uni_data_source = "") |>
    select(-university)

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

  filename <- "tasks/university_covariates/hand/raw_uni_match.csv"
  reduce(patterns, function(mpeds_iteration, matcher){
    mpeds_iteration |>
      mutate(alt_name = str_replace(
          name,
          # if `pattern` isn't given, append `repl` to the end of a word
          ifelse(is.null(matcher$pattern), "$", matcher$pattern),
          matcher$repl)) |>
      left_join(authoritative_uni_matcher, by = c("alt_name" = "uni_name"),
                multiple = "all") |>
      mutate(
        # if is_authoritative is TRUE, then the new rule helped find a match
        # case_when() needed since ipeds_dummy is TRUE or NA, not TRUE or FALSE
        name = case_when(
          is_authoritative ~ alt_name,
          TRUE ~ name
        ),
        uni_id = case_when(
          is_authoritative ~ id,
          TRUE ~ uni_id,
        ),
        uni_data_source = case_when(
          is_authoritative ~ data_source,
          TRUE ~ uni_data_source
        )) |>
      select(-is_authoritative, -alt_name, -id, -data_source)
  }, .init = mpeds_names) |>
    # final match to know which are correct and which need adjustments
    left_join(authoritative_uni_matcher, by = c("name" = "uni_name"),
              multiple = "all") |>
    mutate(is_authoritative = case_when(
      is_authoritative == TRUE ~ TRUE,
      TRUE ~ FALSE
      )) |>
    arrange(is_authoritative) |>
    select(original_name = og_name,
           authoritative_name = name,
           uni_id, uni_data_source) |>
    write_csv(filename)

  return(filename)
}

#' updates to the matching method or underlying data will create
#' changes to the raw coarse match file that have to be propagated
#' to the cleaned coarse match file. For the first pass (catching the majority)
#' that was done manually be me;
#' This function propagates changes so that the undergrad RAs can catch
#' future changes
update_coarse_matches <- function(raw_coarse_filename){
  raw_coarse <- read_csv(raw_coarse_filename, show_col_types = FALSE)
  coarse_filename <- "tasks/university_covariates/hand/coarse_uni_match.csv"
  cleaned_coarse <- read_csv(coarse_filename, show_col_types = FALSE) |>
    full_join(raw_coarse, by = "original_name") |>
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
postprocess_names <- function(geocoded, coarse_uni_match_filename, glued, ipeds){
  coarse_uni_match <- read_csv(coarse_uni_match_filename, show_col_types = FALSE)
  # Creating a keys dataframe so that coders can reference canonical event keys
  # for names
  initial_keys <- geocoded |> select(key, university) |> unnest(university)
  keys <- geocoded |> select(key, participating_universities) |>
    unnest(participating_universities) |>
    rename(university = participating_universities) |>
    bind_rows(initial_keys) |>
    mutate(university = str_remove_all(university, ",") |> str_trim())

  postprocess_filename <- "tasks/university_covariates/hand/university_names_verification.xlsx"
  MPEDS <- coarse_uni_match |>
    mutate(authoritative_name = ifelse(
      !is.na(authoritative_name),
      authoritative_name,
      original_name)) |>
    left_join(keys, by = c("original_name" = "university")) |>
    select(original_name, authoritative_name, uni_id, uni_data_source,
           canonical_event_key = key) |>
    mutate(notes = "")

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

