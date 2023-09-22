# The functions here create "issue clusters". See discussion of issue clusters in Oliver, Lim,
# Matthews, Hanna (2022).
# Ours is a bit different -- we're (at least for now) trying to create issue
# clusters empirically instead of by hand.
create_distance_matrix <- function(cluster_inputs){
  cluster_inputs <- select(cluster_inputs, -key)

  # Geographic distance matrix
  geo_distances <- st_distance(cluster_inputs$geometry, cluster_inputs$geometry)
  # closer to 1 = closer to each other geographically
  geo_distances <- 1 - geo_distances/max(geo_distances, na.rm = TRUE)
  cluster_inputs <- select(cluster_inputs, -geometry)

  base_weights <- c(
    issue = 1,
    start_date = 2,
    racial_issue = 1
  )
  weights <- base_weights |>
    lmap(\(weight){
      matches <- str_subset(names(cluster_inputs), paste0("^", names(weight)))
      multiplier <- 1 / length(matches)
      list(rep(multiplier, length(matches)) |> set_names(matches))
    }) |>
    unlist()
  min_weight <- min(weights)
  weights <- weights[names(cluster_inputs)] * 1 / min(weights)

  # distance (by gower) for the rest of the columns
  distance_matrix <- cluster_inputs |>
    daisy(metric = "gower",
          warnAsym = FALSE,
          weights = weights
          ) |>
    as.matrix()

  # computed weights average of daisy() distances with geographic distances
  # Daisy weights for technical reasons are scaled so that the minimum is 1, so
  # we have to make the corresponding adjustment for the geographic distance
  og_geo_weight <- 1
  geo_weight <- 1/min_weight * og_geo_weight
  total_weight <- 1/(sum(weights) + geo_weight)
  distance_matrix <- sum(weights)/total_weight * distance_matrix + geo_weight * geo_distances
  return(distance_matrix)
}
