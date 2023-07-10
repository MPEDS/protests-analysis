get_missing_dates <- function(){
  missing_dates <- tar_read(integrated) |>
    filter(is.na(start_date) | is.na(as.Date(start_date))) |>
    mutate(
      is_virtual = str_detect(key, "Virtual"),
      is_umbrella = str_detect(key, "^Umbrella"),
      missing_location = st_is_empty(geometry)
    ) |>
    st_drop_geometry() |>
    filter(!is_virtual, !is_umbrella) |>
    select(canonical_id, key, start_date, missing_location)

  missing_dates
}
