get_athletes <- function(){
  tar_load(integrated)

  # Captures four words, to be used to provide context on matches
  padder <- "(?:\\S*\\s*){4}"
  patterns <- c(
    "athlete",
    "sport",
    "player"
  )
  extract_patterns <- paste0(padder, "(", patterns, ")", padder)

  athlete <- integrated |>
    st_drop_geometry() |>
    filter(
      str_detect(description, "athlete|sport|player")
    )

  descriptions_extract <- map_dfr(patterns, \(pattern){
    tibble(
      key = athlete$key,
      pattern = pattern,
      extract = str_extract_all(athlete$description, paste0(padder, "(", pattern, ")", padder)),
    )
  })

  descriptions_extract <- descriptions_extract |>
    unnest(extract) |>
    mutate(extract = paste0("...", extract, "...")) |>
    group_by(key, pattern) |>
    summarize(extract = paste0(extract, collapse = "\n"), .groups = "drop") |>
    mutate(pattern = paste0(pattern, "_match")) |>
    pivot_wider(names_from = pattern, values_from = extract)

  athlete |>
    left_join(descriptions_extract, by = "key") |>
    select(key, names(descriptions_extract), description, publication,
           start_date, form, issue, racial_issue,
           university_reactions_to_protest, university_discourse_on_protest,
           university_discourse_on_issue, university_action_on_issue,
           police_activities
          ) |>
    mutate(across(where(is.list), ~map_chr(., ~paste0(
      .[!(. %in% c("NA/Unclear", "_Not relevant"))], collapse = ", "))
      ))

}
