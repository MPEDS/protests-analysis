get_lgbt_issues <- function(){
  tar_read(integrated) |>
    st_drop_geometry() |>
    select(key, issue) |>
    unnest(issue) |>
    filter(issue %in% c("LGB+/Sexual orientation", "LGB+/Sexual orientation (For)")) |>
    mutate(value = TRUE) |>
    pivot_wider(names_from = issue)

}
