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
  cluster_inputs <- geocoded|>
    st_drop_geometry() |>
    select(key, issue, racial_issue) |>
    unnest(issue) |>
    distinct() |>
    mutate(dummy = TRUE, issue = paste0("issue__", issue)) |>
    pivot_wider(names_from = issue, values_from = dummy, values_fill = FALSE) |>
    unnest(racial_issue) |>
    distinct() |>
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
          weights = weights) |>
    as.matrix()

  # add in the geographic distances
  distance_matrix <- sum(weights)/(1+sum(weights)) + distance_matrix + 1/sum(weights) * geo_distances

  start <- Sys.time()
  clusters <- pam(distance_matrix, k = 200, diss = TRUE)
  message(Sys.time() - start)

  sil_width <- NA
  for(i in 2:10){
    pam_fit <- pam(distance_matrix,
                   diss = TRUE,
                   k = i)
    sil_width[i] <- pam_fit$silinfo$avg.width

  }

  # Plot sihouette width (higher is better)
  plot(1:10, sil_width,
       xlab = "Number of clusters",
       ylab = "Silhouette Width")
  lines(1:10, sil_width)

  # pivot list-cols into one column each
  # create weights list so that each original column has about equal weight

  cluster_assignments <- cluster_assignments |>
    group_by(key) |>
    summarize(cluster_id = list(cluster_id))
  geocoded |>
    left_join(cluster_assignments, by = "key")
}
