#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    geocoded,
    ipeds, glued,
    uni_xwalk,
    us_covariates,
    canada_covariates,
    ccc,
    canada_cma_shapes,
    us_regions
){
  us_counties <- counties(keep_zipped_shapefile = TRUE) |>
    select(fips = GEOID, county_name = NAMELSAD) |>
    st_transform(4326)

  # For now, duplicates exist within the university crosswalk
  # because there are multiple possible options for a given school's true
  # name. The RAs will correct this, so for now I'm just taking the first one
  uni_xwalk <- uni_xwalk |>
    group_by(original_name, canonical_event_key) |>
    slice_head(n = 1) |>
    ungroup()

  # for now convert "university" to simple column and match on that
  with_university_covariates <- geocoded |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) |>
    left_join(select(uni_xwalk, -notes),
              by = c(university = "original_name", key = "canonical_event_key"),
              multiple = "all") |>
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

  # Appending county FIPS code based on spatial join
  # Using EPSG:4326 because that's what Google Earth uses for (geographic)
  # coordinates, and we used Google APIs o get the coords
  with_fips <- with_university_covariates |>
    st_as_sf(coords = c("location_lng", "location_lat"),
             crs = st_crs(4326),
             na.fail = FALSE) |>
    st_join(us_counties) |>
    mutate()

  # Same for Canadian covariates

  with_contextual_covariates <- list(with_fips, us_covariates) |>
    reduce(left_join, by = c("fips", "year"))
    # list() |>
    # list(canada_covariates) |>
    # flatten()

  # Performing a spatial join with the canada shapefiles and (regular) join
  # with US regions
  with_regions <- with_county_covariates |>
    st_join(canada_cma_shapes, st_within) |>
    mutate(state = str_sub(fips, 1, 2)) |>
    left_join(us_regions, by = "state")

  return(with_regions)
}
