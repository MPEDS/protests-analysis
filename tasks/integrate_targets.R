#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    geocoded,
    ipeds, glued,
    uni_xwalk,
    covariates,
    geo
){
  # For now, duplicates exist within the university crosswalk
  # because there are multiple possible options for a given school's true
  # name. The RAs will correct this, so for now I'm just taking the first one
  uni_xwalk <- uni_xwalk |>
    group_by(original_name, canonical_event_key) |>
    select(-description, -notes) |>
    slice_head(n = 1) |>
    ungroup()

  # for now convert "university" to simple column and match on that
  with_university_covariates <- geocoded |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) |>
    left_join(uni_xwalk,
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

  # Appending geographic identifiers via a spatial join
  # Geographic IDs follow a code of the form "us_{county fips code}" for US areas
  # and "canada_{CMA-level GUID}" for Canadian areas
  with_geo <- with_university_covariates |>
    st_as_sf(coords = c("location_lng", "location_lat"),
             crs = st_crs(4326),
             na.fail = FALSE) |>
    st_transform(4269) |>
    st_join(geo) |>
    left_join(covariates, by = c("geoid", "year"))

  return(with_geo)
}
