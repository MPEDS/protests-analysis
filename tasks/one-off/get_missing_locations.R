get_missing_locations <- function(){
  missing_locations <- tar_read(integrated) |>
    filter(st_is_empty(geometry)) |>
    st_drop_geometry() |>
    select(key) |>
    mutate(
      is_virtual = str_detect(key, "Virtual"),
      is_umbrella = str_detect(key, "^Umbrella")
    )

  return(missing_locations)
}
