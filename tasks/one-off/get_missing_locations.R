get_missing_locations <- function(){
  missing_locations <- tar_read(integrated) |>
    filter(st_is_empty(geometry)) |>
    st_drop_geometry() |>
    mutate(
      is_virtual = str_detect(key, "Virtual"),
      is_umbrella = str_detect(key, "^Umbrella"),
    ) |>
    filter(!is_virtual, !is_umbrella) |>
    select(canonical_id, key)

  canonical_event_link <- get_filtered_candidate_events()

  missing_locations |>
    left_join(canonical_event_link, by = "canonical_id") |>
    select(-canonical_id)
}
