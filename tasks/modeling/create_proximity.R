# Time-varying indicator -- distance to closest site of protest that happened
# in the past week
# See https://stat.ethz.ch/R-manual/R-devel/library/survival/doc/timedep.pdf
# for conceptual notes -- whether it's ok to have one observation
create_proximity <- function(timeseries){
  unis <- timeseries |>
    select(uni_id, geometry) |>
    filter(!st_is_empty(geometry)) |>
    distinct()

  dists <- unis |>
    st_distance()
  units(dists) <- NULL

  colnames(dists) <- unis$uni_id
  # List for fast lookup of uni IDs against indexes
  uni_ids <- as.list(seq_along(unis$uni_id)) |> set_names(unis$uni_id)
  dists <- as_tibble(dists)

  # Construct crosswalk of all possible dates
  possible_dates <- expand_grid(
    current_date = seq(min(timeseries$start_date, na.rm = T),
                max(timeseries$start_date, na.rm = T),
                by = 1),
    uni_id = unique(timeseries$uni_id)
  )

  # For each day, get university IDs of campuses that had protests in past week
  dta <- timeseries |>
    st_drop_geometry() |>
    filter(had_hazard_status, uni_id %in% unis$uni_id)
  protest_dates <- map(unique(possible_dates$current_date), \(date){
    dta |>
      filter(start_date < date, start_date > date - 7) |>
      pull(uni_id)
  }) |>
    set_names(unique(possible_dates$current_date))

  # For each university, for each point in time, calculate the mean of
  # (1 if protest at other uni in past week / distance to this university)
  # The data up to this step has one row per date, but after it will
  # be long-on-interval, where an interval is the longest stretch
  # of time for which a university holds a particular value for spatial proximity
  # For most universities, this will be just one day, of the form (12, 13]
  with_proximity <- timeseries |>
    drop_na(start_date) |>
    st_drop_geometry() |>
    full_join(
      possible_dates, by = "uni_id",
    ) |>
    mutate(proximity = map2_dbl(uni_id, as.character(current_date), \(id, date){
      uni_idx <- uni_ids[[id]]
      previous_protest_unis <- unlist(uni_ids[protest_dates[[date]]])
      protest_distances <- unlist(dists[uni_idx, previous_protest_unis])

      # To get the weight, take the inverse of distance and consider 0s for all
      # of the schools that did not have protests, then average
      weight <- c(
        1/sqrt(protest_distances),
        rep(0, length(timeseries$uni_id) - length(protest_distances))
      ) |>
        mean()

      weight
    }, .progress = TRUE))

  # TODO Finally, transform so that data is long-on-interval instead of long-on-day
  # Data will have a start and end date column to mark interval for each row
  with_proximity
}

