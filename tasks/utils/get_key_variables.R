get_key_variables <- function(dta, ...){
  source("tasks/utils/pick_university.R")
  dta |>
    st_drop_geometry() |>
    mutate(
      canonical_id = as.integer(canonical_id),
      # Publication if present, uni where protest occurs if otherwise
      main_university = map_chr(university, pick_university),
    ) |>
    select(
      canonical_id, key, description, publication, start_date,
      location, main_university, issue, racial_issue,
      ...
    ) |>
    mutate(across(c(issue, racial_issue), ~map_chr(., ~paste0(.[. != "_Not relevant"], collapse = ", "))))
}
