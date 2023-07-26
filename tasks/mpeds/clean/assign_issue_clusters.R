# The functions here create "issue clusters". See discussion of issue clusters in Oliver, Lim,
# Matthews, Hanna (2022).
# Ours is a bit different -- we're (at least for now) trying to create issue
# clusters empirically instead of by hand.
# This is a VERY inefficient algorithm. I never took an algo class 💀

assign_clusters <- function(geocoded, canonical_event_relationship){
  geocoded <- geocoded |>
    st_as_sf(coords = c("location_lng", "location_lat"), na.fail = FALSE) |>
    filter(!st_is_empty(geometry))

  # Select only columns that will be used for clustering
  # Just using issue and racial_issue for now for proof of concept/prototype run
  geometries <- geocoded|>
    select(key)
  cluster_inputs <- geocoded |>
    st_drop_geometry() |>
    select(key, start_date, issue, racial_issue) |>
    mutate(start_date = as.numeric(as.Date(y) - as.Date("2012-01-01")),
           across(c(racial_issue, issue), ~ifelse(. == "", NA_character_, .))) |>
    unnest(issue) |>
    distinct() |>
    filter(!is.na(issue), issue != "") |>
    mutate(dummy = TRUE, issue = paste0("issue__", issue)) |>
    pivot_wider(names_from = issue, values_from = dummy, values_fill = FALSE) |>
    unnest(racial_issue) |>
    distinct() |>
    filter(!is.na(racial_issue), racial_issue != "") |>
    mutate(dummy = TRUE, racial_issue = paste0("racial_issue__", racial_issue)) |>
    pivot_wider(names_from = racial_issue, values_from = dummy,
                values_fill = FALSE) |>
    left_join(geometries, by = "key") |>
    select(-contains("Not relevant"), -key)

  # Geographic distance matrix
  geo_distances <- st_distance(cluster_inputs$geometry, cluster_inputs$geometry)
  # closer to 1 = closer to each other geographically
  geo_distances <- 1 - geo_distances/max(geo_distances, na.rm = TRUE)
  cluster_inputs <- select(cluster_inputs, -geometry)

  base_weights <- c(
    issue = 1,
    start_date = 1,
    racial_issue = 1
  )
  weights <- base_weights |>
    lmap(\(weight){
      matches <- str_subset(names(cluster_inputs), paste0("^", names(weight)))
      multiplier <- 1 / length(matches)
      list(rep(multiplier, length(matches)) |> set_names(matches))
    }) |>
    unlist()
  weights <- weights[names(cluster_inputs)]

  # distance (by gower) for the rest of the columns
  distance_matrix <- cluster_inputs |>
    daisy(metric = "gower",
          warnAsym = FALSE
          ) |>
    as.matrix()

  # add in the geographic distances
  distance_matrix <- sum(weights)/(1+sum(weights)) + distance_matrix + 1/sum(weights) * geo_distances

  test_ks <- c(50, 100, 250, 500, 750, 1000,
               1200, 1400, 1600, 1800, 2000)

  cluster_metrics <- map_dfr(test_ks[1:2], function(test_k){
    start <- Sys.time()
    clusters <- pam(distance_matrix, k = test_k, diss = TRUE)
    write_csv(tibble(clusters = clusters$clustering),
              paste0(i, ".csv"))

    return(tibble(
      k = test_k,
      time = Sys.time() - start,
      silhouette_width = clusters$silinfo$avg.width,
      clusters = clusters$clustering,
    ))
  })
  return(cluster_metrics)
}
