#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    cleaned_events,
    ipeds, glued,
    uni_xwalk,
    covariates,
    geo
){
  # For now, duplicates exist within the university crosswalk
  # because there are multiple possible options for a given school's true
  # name. The RAs have presumably ensured every row is correct, so I will
  # arbitrarily take the first row
  # uni_xwalk <- uni_xwalk |>
  #   group_by(original_name, canonical_event_key) |>
  #   select(-description, -notes, -seen, ) |>
  #   slice_head(n = 1) |>
  #   ungroup()

  uni_xwalk <- uni_xwalk |>
    select(canonical_event_key, uni_id = authoritative_id,
           authoritative_name, original_name,
           source = original_source) |>
    filter(source != "participating-universities-text")

  uni_contextual <- bind_rows(ipeds, glued)

  with_university_covariates <- cleaned_events |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .)),
      start_date = as.Date(start_date),
      year = lubridate::year(start_date)) |>
    full_join(uni_xwalk, by = c(key = "canonical_event_key")) |>
    left_join(uni_contextual, by = c("uni_id", "year")) |>
    nest(data = c(uni_id, authoritative_name, original_name, source, names(uni_contextual), -year))

  # Sanity checks to make sure the process is working
  # which events were not in spreadsheet but in DB
  missing_keys <- setdiff(cleaned_events$key, uni_xwalk$canonical_event_key)
  # which events were added in spreadsheet but were not present
  extra_keys <- setdiff(uni_xwalk$canonical_event_key, cleaned_events$key)

  # x <- with_university_covariates |>
  #   unnest(participating_universities_text, keep_empty = TRUE) |>
  #   left_join(participating_xwalk, by = c(
  #     key = "canonical_event_key", participating_universities_text = "original_name"
  #   )) |>
  #   nest(data = c(participating_universities_text, uni_id))
  #

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
