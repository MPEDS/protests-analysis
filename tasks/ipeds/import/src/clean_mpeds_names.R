# Matches IPEDS and MPEDS names together
# Going to be tough -- the names MPEDS uses and the names IPEDS uses
# don't follow the same conventions.
# I'd even say (after perusing the codebook) that the MPEDS
# names do not follow any predetermined convention

# So this will work in a two-stage pass: first we'll do some basic matches/rules
# to see what MPEDS names have an IPEDS counterpart, and export the remainder
# (e.g. unmatched) to a local CSV. The second pass will involve manually
# writing down corresponding IPEDS names for each unmatched MPEDS name.

#' First pass function- helps dedup/correct names in MPEDS
#' @param geocoded canonical events with geocoded names (the `geocoded` target)
#' @param uni_directory The university directory from IPEDS
clean_mpeds_names <- function(geocoded, uni_directory){
  mpeds_names <- c(
      geocoded$university,
      geocoded$participating_universities
    ) |>
    str_remove_all(",") |>
    str_trim() |>
    unlist() |>
    unique() |>
    {\(.) tibble(name = ., og_name = .)}()
  ipeds_matcher <- select(uni_directory, name) |>
    mutate(ipeds_dummy = TRUE) |>
    distinct()
  filename <- "tasks/ipeds/hand/raw_ipeds_match.csv"

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
    list(pattern = "\\s(?!\\S*\\s)", repl = "-"),
    list(pattern = "\\s(?!\\S*\\s)", repl = "-"),
    list(repl = " University"),
    list(repl = " College"),
    list(repl = "-Main Campus"),
    list(repl = " School")
  )

  reduce(patterns, function(prev_tbl, matcher){
    prev_tbl |>
      drop_na() |>
      mutate(alt_name = str_replace(
          name,
          # if "pattern" isn't given, append it to the end of a word ("$" in regex)
          if_else(is.null(matcher$pattern), "$", matcher$pattern),
          matcher$repl)) |>
      left_join(ipeds_matcher, by = c("alt_name" = "name")) |>
      mutate(
        # if ipeds_dummy is TRUE, then the new rule helped find a match
        # case_when() needed since ipeds_dummy is TRUE or NA, not TRUE or FALSE
        name = case_when(
          ipeds_dummy == TRUE ~ alt_name,
          TRUE ~ name
        )) |>
      select(-ipeds_dummy, -alt_name)
  }, .init = mpeds_names) |>
    # final match to know which are correct and which need adjustments
    left_join(ipeds_matcher, by = "name") |>
    mutate(ipeds_dummy = case_when(ipeds_dummy == TRUE ~ TRUE, TRUE ~ FALSE)) |>
    arrange(ipeds_dummy) |>
    write_csv(filename)

  return(filename)
}

#' exports IPEDS info itself
export_ipeds <- function(){
  tar_read(uni_directory) |>
    pull(name) |>
    unique() |>
    {\(.) tibble(ipeds_names = .)}() |>
    write_csv("tasks/ipeds/hand/ipeds_names.csv")
}

#' after I cleaned the names, process them once more to
postprocess_names <- function(geocoded, cleaned_ipeds_match_filename){
  cleaned_ipeds_match <- read_csv(cleaned_ipeds_match_filename)
  # Creating a keys dataframe so that coders can reference canonical event keys
  # for names
  keys <- geocoded |> select(key, university) |> unnest(university)
  keys <- geocoded |> select(key, participating_universities) |>
    unnest(participating_universities) |>
    rename(university = participating_universities) |>
    bind_rows(keys) |>
    mutate(university = str_remove_all(university, ",") |> str_trim()) |>
    group_by(university) |>
    summarize(key = str_c(key, sep = ","), .groups = "drop")

  postprocess_filename <- "tasks/ipeds/hand/ipeds_verification.csv"
  cleaned_ipeds_match |>
    mutate(ipeds_name = ifelse(!is.na(true_name), true_name, name)) |>
    # since coders can't currently verify canadian unis, we exclude
    filter(is.na(canada)) |>
    left_join(keys, by = c("og_name" = "university")) |>
    select(raw_name = og_name, ipeds_name, canonical_event_key = key) |>
    mutate(notes = "") |>
    write_csv(postprocess_filename)

  return(postprocess_filename)
}

