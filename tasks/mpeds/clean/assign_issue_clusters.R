# The functions here create "issue clusters". See discussion of issue clusters in Oliver, Lim,
# Matthews, Hanna (2022).
# Ours is a bit different -- we're (at least for now) trying to create issue
# clusters empirically instead of by hand.
# This is a VERY inefficient algorithm. I never took an algo class 💀

# weights = c(
#   column_name = integer
# )
compute_distance <- function(event1, event2, points, geo_distances, weights){
  time1 <- Sys.time()
  # First get geocoding distance
  geo_dist <- c(
    geo_dist = geo_distances[event1$point_id, event2$point_id]
  )

  # Then compute numerical distances (Manhattan (yuck))
  # Just kidding we don't have any right now

  time2 <- Sys.time()
  # Then categorical distances (Dice), which is just the campaign name for us
  # right now
  cols <- event1 |> select(where(is.character), where(is.factor)) |> names()
  categorical_values <- map_dbl(cols, \(col){
    diff <- isTRUE(event1[[col]] == event2[[col]])
    diff <- ifelse(event1[[col]], FALSE, diff)
    return(as.numeric(diff))
  }) |>
    set_names(cols)

  time3 <- Sys.time()
  # Then binary variables, which are pivoted list-cols for this analysis
  cols <- event1 |> select(where(is.logical)) |> names()
  binary_values <- map_dbl(cols, \(col){
    as.numeric(isTRUE(event1[[col]] && event2[[col]]))
  }) |>
    set_names(cols)

  time4 <- Sys.time()
  values <- c(geo_dist, categorical_values, binary_values)
  score <- sum(values * weights[names(values)], na.rm = TRUE)

  time5 <- Sys.time()
  print(c(time1 = time2-time1, time2 = time3 - time2, time3 = time4 - time3, time4 = time5 - time4))
  return(score)
}

assign_clusters <- function(geocoded, canonical_event_relationship){
  # Precompute spatial distances, since we have some functions for doing that
  # up front
  geocoded <- geocoded |>
    st_as_sf(coords = c("location_lng", "location_lat"), na.fail = FALSE)
  points <- geocoded |>
    select() |>
    distinct() |>
    pull(geometry)
  geo_distances <- st_distance(points, points)
  # closer to 1 = closer to each other geographically
  geo_distances <- 1 - geo_distances/max(geo_distances, na.rm = TRUE)

  # Join campaign column
  campaigns <- canonical_event_relationship |>
    filter(relationship_type == "campaign") |>
    group_by(canonical_id1) |>
    slice_head(n = 1)
  geocoded <- geocoded |>
    left_join(campaigns, by = c("canonical_id" = "canonical_id1")) |>
    rename(campaign_id = canonical_id2) |>
    mutate(campaign_id = ifelse(is.na(campaign_id), 0, campaign_id),
           campaign_id = as.character(campaign_id))

  # Select only columns that will be used for clustering
  # Just using issue and racial_issue for now for proof of concept/prototype run
  geometry <- geocoded |> select(key)
  geocoded <- geocoded[1:100,] |>
    st_drop_geometry() |>
    select(key, campaign_id, issue, racial_issue) |>
    unnest(issue) |>
    distinct() |>
    mutate(dummy = TRUE, issue = paste0("issue__", issue)) |>
    pivot_wider(names_from = issue, values_from = dummy, values_fill = FALSE) |>
    unnest(racial_issue) |>
    distinct() |>
    mutate(dummy = TRUE, racial_issue = paste0("racial_issue__", racial_issue)) |>
    pivot_wider(names_from = racial_issue, values_from = dummy,
                values_fill = FALSE) |>
    left_join(geometry, by = "key") |>
    mutate(point_id = lmap(geometry, ~list(which(points == .))) |>
             unlist()) |>
    select(-contains("Not relevant"), -key)

  base_weights <- c(
    campaign_id = 1,
    issue = 1,
    racial_issue = 1
  )
  weights <- base_weights |>
    lmap(\(weight){
      matches <- str_subset(names(geocoded), paste0("^", names(weight)))
      multiplier <- 1 / length(matches)
      list(rep(multiplier, length(matches)) |> set_names(matches))
    })
  weights <- c(geo_dist = 1, weights) |> unlist()

  iterable_grid <- expand_grid(event1 = 1:nrow(geocoded), event2 = 1:nrow(geocoded)) |>
    filter(event1 < event2)

  start <- Sys.time()
  distances <- iterable_grid[1:100,] |>
    mutate(distances = map2_dbl(event1, event2, \(id1, id2){
      compute_distance(geocoded[id1,], geocoded[id2,], points, geo_distances, weights)
    }, .progress = TRUE))
  message(Sys.time() - start)

  # pivot list-cols into one column each
  # create weights list so that each original column has about equal weight
  # save for campaign, which is weighted way more heavily

  cluster_assignments <- cluster_assignments |>
    group_by(key) |>
    summarize(cluster_id = list(cluster_id))
  geocoded |>
    left_join(cluster_assignments, by = "key")
}
