get_lgbt_issues <- function(){
  tar_read(integrated) |>
    st_drop_geometry() |>
    select(key, issue) |>
    unnest(issue) |>
    filter(str_detect(issue, "LGB")) |>
    mutate(value = TRUE) |>
    pivot_wider(names_from = issue)
}
