create_cluster_inputs <- function(cleaned_events){
  cleaned_events <- cleaned_events |>
    st_as_sf(coords = c("location_lng", "location_lat"), na.fail = FALSE) |>
    filter(!st_is_empty(geometry))

  # Select only columns that will be used for clustering
  # Just using issue and racial_issue for now for proof of concept/prototype run
  geometries <- cleaned_events |>
    select(key)
  cluster_inputs <- cleaned_events |>
    st_drop_geometry() |>
    select(key, start_date, issue, racial_issue) |>
    mutate(start_date = as.numeric(as.Date(start_date) - as.Date("2012-01-01")),
           across(c(racial_issue, issue), ~ifelse(. == "", NA_character_, .))) |>
    unnest(issue) |>
    distinct() |>
    filter(!is.na(issue), issue != "") |>
    mutate(dummy = TRUE, issue = paste0("issue__", issue)) |>
    pivot_wider(names_from = issue, values_from = dummy, values_fill = FALSE) |>
    unnest(racial_issue) |>
    distinct() |>
    filter(!is.na(racial_issue), racial_issue != "") |>
    mutate(dummy = TRUE, racial_issue = paste0("racial_issue__", racial_issue)) |>
    pivot_wider(names_from = racial_issue, values_from = dummy,
                values_fill = FALSE) |>
    left_join(geometries, by = "key") |>
    select(-contains("Not relevant")) |>
    janitor::clean_names()

  return(cluster_inputs)
}
