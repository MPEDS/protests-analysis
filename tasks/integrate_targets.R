#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(cleaned_events,
                              ipeds,
                              glued,
                              uni_xwalk,
                              covariates,
                              geo) {
  uni_xwalk <- uni_xwalk |>
    select(
      canonical_id,
      uni_id,
      original_name,
      authoritative_name,
      source
    ) |>
    mutate(
      source = str_replace_all(source, "-", "_"),
      original_name = ifelse(is.na(original_name), authoritative_name, original_name)
    ) |>
    select(-authoritative_name)

  uni_contextual <- bind_rows(ipeds, glued)

  with_university_covariates <- cleaned_events |>
    mutate(
      start_date = as.Date(start_date),
      year = lubridate::year(start_date),
      canonical_id = as.character(canonical_id),
      university = pmap(list(university, canonical_id, year), \(x, y, z) {
        x |> mutate(canonical_id = y, year = z)
      })
    ) |>
    nest_left_join(
      university,
      uni_xwalk,
      by = c("university_name" = "original_name",
             "canonical_id",
             "uni_name_source" = "source")
    ) |>
    nest_left_join(
      university,
      uni_contextual,
      by = c("uni_id", "year")
    ) |>
    nest_select(university, -university_name)

  # Sanity checks to make sure the process is working
  # which events were not in spreadsheet but in DB
  missing_keys <- setdiff(cleaned_events$key, uni_xwalk$canonical_event_key)
  # which events were added in spreadsheet but were not present
  extra_keys <- setdiff(uni_xwalk$canonical_event_key, cleaned_events$key)

  # Appending geographic identifiers via a spatial join
  # Geographic IDs follow a code of the form "us_{county fips code}" for US areas
  # and "canada_{CMA-level GUID}" for Canadian areas
  with_geo <- with_university_covariates |>
    st_as_sf(
      coords = c("location_lng", "location_lat"),
      crs = st_crs(4326),
      na.fail = FALSE
    ) |>
    st_transform(4269) |>
    st_join(geo) |>
    left_join(covariates, by = c("geoid", "year"))

  return(with_geo)
}
