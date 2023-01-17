#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    geocoded,
    uni_directory,
    ipeds_xwalk,
    county_covariates = list(),
    ccc,
    uni_covariates = list(),
    canada_shapefiles
){
  # for now convert "university" to simple column and match on that
  with_ipeds <- geocoded |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) |>
    left_join(rename(ipeds_xwalk, uni_id = id), by = c(university = "og_name")) |>
    mutate(
      university = case_when(
        !is.na(true_name) ~ true_name,
        TRUE ~ university
      )
    ) |>
  # get a clean year for the start date -- only one currently that has two, have to debug
    mutate(start_date = map_chr(start_date, ~ifelse(is.null(.), NA_character_, .[1])),
           start_date = as.Date(start_date),
           year = lubridate::year(start_date)) |>
    left_join(uni_directory, by = c("uni_id" = "id", "year"))

  # can't figure out how to normally append a tibble as the first item of
  # the list lol so instead I'll do it this way
  with_covariates <- list(list(with_ipeds), county_covariates) |>
    flatten() |>
    reduce(left_join, by = c("fips", "year"))

  # Converting to sf format
  # and performing a spatial join with the canada shapefiles
  # Using EPSG:4326 because that's what Google Earth uses for (geographic)
  # coordinates, and we used Google APIs o get the coords
  with_canada_census_subdivision <- with_covariates |>
    st_as_sf(coords = c("location_lng", "location_lat"), crs = st_crs(4326),
             na.fail = FALSE) |>
    st_join(canada_shapefiles, st_within)

  return(with_covariates)
}
