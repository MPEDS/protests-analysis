# Create "issue clusters". See discussion of issue clusters in Oliver, Lim,
# Matthews, Hanna (2022).
# Ours is a bit different -- we're (at least for now) trying to create issue
# clusters empirically instead of by hand.
# For now this works by grouping all protests on the same issue within a given
# location, and then for each group finding the n-day window that
# contains the most events. Then repeating until all events have been assigned
# to a cluster.
# This is a VERY inefficient algorithm. I never took an algo class 💀
assign_issue_clusters <- function(geocoded, n){
  issue_long <- geocoded |>
    select(key, start_date, location, issue, racial_issue) |>
    pivot_longer(cols = c(issue, racial_issue)) |>
    unnest(cols = value) |>
    mutate(start_date = as.Date(start_date)) |>
    filter(value != "_Not relevant", !is.na(start_date), !is.na(location)) |>
    mutate(
       # Just to force differentiation between plain issues and racial issues
       value = paste0(value, name)
    ) |>
    rename(issue = value)

  # split events into groups based on location and issue
  # while loop until all keys have been assigned
  cluster_assignments <- issue_long |>
    group_by(location, issue) |>
    group_split() |>
    imap_dfr(\(group_dta, group_index){
      reduce(unique(group_dta$start_date), function(state, date){
        available_events <- state$available_events
        cluster_assignments <- state$cluster_assignments
        if(nrow(available_events) == 0){
          return(state)
        }
        # tabulate number of events for n-day period starting on every given day
        # in dataset
        day_counts <- map_dfr(unique(available_events$start_date), \(test_date){
          count <- available_events |>
            filter(start_date >= test_date, start_date <= test_date + n) |>
            nrow()
          return(tibble(test_date, count))
        })
        best_day <- day_counts |>
          slice_max(count, with_ties = FALSE) |>
          pull(test_date)

        # pull those that match into their own group
        in_cluster_keys <- available_events |>
          filter(start_date >= best_day, start_date <= best_day + n) |>
          pull(key)
        out_cluster <- available_events |>
          filter(!(key %in% in_cluster_keys))

        new_state <- list(
          available_events = out_cluster,
          cluster_assignments = bind_rows(cluster_assignments, tibble(
            key = in_cluster_keys, cluster_id = paste0(group_index, "_", date)
          ))
        )
        return(new_state)
      }, .init = list(available_events = group_dta, cluster_assignments = tibble()))$cluster_assignments
    }, .progress = TRUE)

  # join onto events
  cluster_assignments <- cluster_assignments |>
    group_by(key) |>
    summarize(cluster_id = list(cluster_id))
  geocoded |>
    left_join(cluster_assignments, by = "key")
}
