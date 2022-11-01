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
#' @param events canonical events with geocoded names (the `geocoded` target)
#' @param ipeds The university directory from IPEDS
clean_mpeds_names <- function(events, ipeds){
  mpeds_names <- c(
      events$university,
      events$participating_universities
    ) %>%
    str_remove_all(",") %>%
    str_trim() %>%
    unlist() %>%
    unique() %>%
    tibble(name = ., og_name = .)
  ipeds_matcher <- select(ipeds, name) %>%
    mutate(ipeds_dummy = TRUE) %>%
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
    prev_tbl %>%
      drop_na() %>%
      mutate(alt_name = str_replace(
          name,
          # if "pattern" isn't given, append it to the end of a word ("$" in regex)
          if_else(is.null(matcher$pattern), "$", matcher$pattern),
          matcher$repl)) %>%
      left_join(ipeds_matcher, by = c("alt_name" = "name")) %>%
      mutate(
        # if ipeds_dummy is TRUE, then the new rule helped find a match
        # case_when() needed since ipeds_dummy is TRUE or NA, not TRUE or FALSE
        name = case_when(
          ipeds_dummy == TRUE ~ alt_name,
          TRUE ~ name
        )) %>%
      select(-ipeds_dummy, -alt_name)
  }, .init = mpeds_names) %>%
    # final match to know which are correct and which need adjustments
    left_join(ipeds_matcher, by = "name") %>%
    mutate(ipeds_dummy = case_when(ipeds_dummy == TRUE ~ TRUE, TRUE ~ FALSE)) %>%
    arrange(ipeds_dummy) %>%
    write_csv(filename)

  return(filename)
}

#' exports IPEDS info itself
export_ipeds <- function(){
  tar_read(uni_directory) %>%
    pull(name) %>%
    unique() %>%
    tibble(ipeds_names = .) %>%
    write_csv("tasks/ipeds/hand/ipeds_names.csv")
}
