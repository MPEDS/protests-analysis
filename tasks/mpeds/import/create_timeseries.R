create_timeseries <- function(integrated, canonical_event_relationship, ipeds, us_covariates, uni_pub_xwalk_reference, us_geo){
  mizzou_id <- integrated |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015-2016_Oct-Feb") |>
    pull(canonical_id)
  mizzou_events_ids <- canonical_event_relationship |>
    filter(canonical_id2 %in% mizzou_id) |>
    pull(canonical_id1)

  mizzou_events <- integrated |>
    filter(canonical_id %in% mizzou_events_ids)

  mizzou_events_cleaned <- mizzou_events |>
    st_drop_geometry() |>
    # University covariates, which are present as a nested tibble, have to have
    # the relevant entry selected and brought out. Convoluted logic
    # that should have its own function, but essentially says "pick 'other univ where protest occurs'"
    # if available, publication if not. And drop all NAs for uni IDs
    nest_select(university, uni_id, uni_name_source) |>
    unnest(university) |>
    group_by(key) |>
    filter(!is.na(uni_id), (uni_name_source %in% c("other univ where protest occurs", "publication"))) |>
    mutate(uni_name_source = factor(uni_name_source, levels = c(
      "other univ where protest occurs", "publication"
      )),
      year = lubridate::year(start_date)) |>
    arrange(key, uni_name_source) |>
    slice_head(n = 1)

  # Filter IPEDS to only include schools within the possible MPEDS universe
  mpeds_universe <- uni_pub_xwalk_reference |>
    # filter(source == "UWIRE Affiliate") |>
    drop_na(uni_id) |>
    pull(uni_id) |>
    unique()
  ipeds_filtered <- ipeds |>
    filter(uni_id %in% mpeds_universe)

  # Picks first hazard (protest) for each university in MPEDS
  mpeds_hazards <- mizzou_events_cleaned |>
    group_by(uni_id) |>
    select(uni_id, start_date, year) |>
    slice_min(start_date, n = 1, with_ties = FALSE) |>
    ungroup()

  # Then joins with rest of IPEDS that are in MPEDS universe
  timeseries <- mpeds_hazards |>
    full_join(ipeds_filtered, by = c("uni_id", "year")) |>
    mutate(
      # Assign (latest possible) date for universities without protests
      protest_age = if_else(
        is.na(start_date), max(mizzou_events$start_date, na.rm = TRUE), start_date
      )
    ) |>
    # We need to do a full join to also get info for schools that didn't have a
    # protest, but this gets additional years' data too --
    # IPEDS includes data from 2014, 2012, etc, so we need to constrain records to the
    # given time period by comparing with the dates joined that cover the
    # specific time period of interest
    filter(year == lubridate::year(protest_age)) |>
    mutate(
      # FALSE = censored at end of study (no protest), TRUE = had hazard (protest)
      had_hazard_status = !is.na(start_date),
      # Protest age becomes "number of days after first mizzou protest (oct 1 2015)"
      protest_age = as.numeric(protest_age - min(mizzou_events$start_date, na.rm = TRUE)),
      tuition = tuition / 1000,
      uni_total_pop = uni_total_pop / 1000,
      ipeds_fips = paste0("us_", ipeds_fips),
      is_uni_public = as.numeric(is_uni_public)
      ) |>
    left_join(us_covariates, by = c("ipeds_fips" = "geoid", "year")) |>
    left_join(us_geo, by = c("ipeds_fips" = "geoid")) |>
    # TODO: get point geometries for all universities
    st_as_sf() |>
    st_centroid()

  return(timeseries)
}


# tar_load_args(create_timeseries)
# timeseries <- create_timeseries(integrated,
#                                 canonical_event_relationship,
#                                 ipeds,
#                                 us_covariates,
#                                 uni_pub_xwalk_reference, us_geo)
