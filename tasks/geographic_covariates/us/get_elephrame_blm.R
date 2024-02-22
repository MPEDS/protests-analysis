# Unable to obtain raw data programmatically because of
# unstandard Javascript-based redirect behavior on Elephrame's
# website
get_elephrame_blm <- function(){
  filename <- tempfile()

  gcs_get_object(
    "inputs/elephrame.json",
    bucket = "mpeds_targets",
    saveToDisk = filename
  )

  county_shps <- counties(progress_bar = FALSE) |>
    suppressMessages() |>
    mutate(fips = paste0(STATEFP, COUNTYFP)) |>
    select(fips)

  # adding county matches to it via a spatial join
  blm <- read_sf(filename) |>
    select(blm_protest_date = start, blm_protest_num = num) |>
    mutate(blm_protest_date = as.Date(blm_protest_date)) |>
    st_set_crs(st_crs(county_shps)) |>
    st_join(county_shps, join = st_within) |>
    st_drop_geometry()

  return(blm)
}
