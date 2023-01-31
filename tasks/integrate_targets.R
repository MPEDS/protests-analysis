#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    geocoded,
    ipeds, glued,
    uni_xwalk,
    county_covariates = list(),
    ccc,
    canada_shapefiles,
    us_regions
){
  # for now convert "university" to simple column and match on that
  with_university_covariates <- geocoded |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) |>
    left_join(select(uni_xwalk, -notes),
              by = c(university = "original_name", key = "canonical_event_key")) |>
    mutate(
      university = case_when(
        !is.na(authoritative_name) ~ authoritative_name,
        TRUE ~ university
      )
    ) |>
    # get a clean year for the start date --
    # only one currently that has two, have to debug
    mutate(start_date = map_chr(start_date, ~ifelse(is.null(.), NA_character_, .[1])),
           start_date = as.Date(start_date),
           year = lubridate::year(start_date)) |>
    left_join(ipeds, by = c("uni_id" = "id", "year")) |>
    left_join(glued, by = c("uni_id" = "glued_id", "year"))

  # can't figure out how to normally append a tibble as the first item of
  # the list lol so instead I'll do it this way
  with_county_covariates <- list(list(with_university_covariates),
                                 county_covariates) |>
    flatten() |>
    reduce(left_join, by = c("fips", "year"))

  # Converting to sf format
  # and performing a spatial join with the canada shapefiles
  # Using EPSG:4326 because that's what Google Earth uses for (geographic)
  # coordinates, and we used Google APIs o get the coords
  with_shapes <- with_county_covariates |>
    st_as_sf(coords = c("location_lng", "location_lat"), crs = st_crs(4326),
             na.fail = FALSE) |>
    st_join(canada_shapefiles, st_within) |>
    mutate(state = str_sub(fips, 1, 2)) |>
    left_join(us_regions, by = "state")

  return(with_shapes)
}
