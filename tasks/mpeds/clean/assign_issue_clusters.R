# The functions here create "issue clusters". See discussion of issue clusters in Oliver, Lim,
# Matthews, Hanna (2022).
# Ours is a bit different -- we're (at least for now) trying to create issue
# clusters empirically instead of by hand.
# This is a VERY inefficient algorithm. I never took an algo class 💀

assign_issue_clusters <- function(geocoded, canonical_event_relationship){
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
    mutate(start_date = as.numeric(as.Date(start_date) - as.Date("2012-01-01")),
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
    select(-contains("Not relevant")) |>
    janitor::clean_names()
  with_key <- cluster_inputs
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

  n_campaigns <- canonical_event_relationship |>
    filter(relationship_type == "campaign") |>
    pull(canonical_id2) |>
    unique() |>
    length()
  test_ks <- c(n_campaigns, 500, 700, 1600, 1800, 2000)

  cluster_metrics <- map_dfr(test_ks, function(test_k){
    start <- Sys.time()
    clusters <- pam(distance_matrix, k = test_k, diss = TRUE, variant = "faster")
    message(Sys.time() - start)
    write_csv(tibble(clusters = clusters$clustering),
              paste0(test_k, ".csv"))

    return(tibble(
      k = test_k,
      time = Sys.time() - start,
      silhouette_width = clusters$silinfo$avg.width,
      clusters = clusters$clustering,
    ))
  })

  clusterings <- map(list.files("metrics", full.names = TRUE),
                  \(filename){
                    read_csv(filename) |>
                      mutate(k = parse_number(filename))
                  })
  ks <- map_int(clusterings, \(cluster){unique(cluster$k)})
  sil_widths <- map_dbl(clusterings, \(cluster){
    sil <- silhouette(cluster$clusters, distance_matrix)
    summary(sil)$avg.width
  })
  tibble(ks, sil_widths) |>
    ggplot(aes(x = ks, y = sil_widths)) +
    geom_point() +
    labs(
      title = "More clusters doesn't imply better fit for us",
      y = "Average silhouette width",
      x = "Number of clusters"
    )

  profiles <- clusterings |>
    map_dfr(\(clustering){
      k <- unique(clustering$k)
      top_clusters <- clustering |>
        group_by(clusters) |>
        count() |>
        ungroup() |>
        slice_max(order_by = n, n = 5)
      events <- with_key |>
        select(key) |>
        mutate(cluster_id = clustering$clusters) |>
        left_join(geocoded, by = "key") |>
        filter(cluster_id %in% top_clusters$clusters)

      # graph of over-time clustering
      over_time <- events |>
        mutate(month = floor_date(as.Date(start_date), unit = "months")) |>
        group_by(cluster_id, month) |>
        count() |>
        ggplot(aes(x = month, y = n, color = as.factor(cluster_id))) +
        geom_line() +
        labs(
          n = "Number of events in cluster",
          color = "Cluster ID",
          x = NULL,
          title = "Event occurrence by cluster over time"
        )
      ggsave(paste0(k, "-over_time.png"), over_time)

      # Map of events
      event_map <- events |>
        st_as_sf() |>
        ggplot(aes(color = as.factor(cluster_id))) +
        geom_sf() +
        lims(x = c(-130, -55),
             y = c(25, 55)) +
        labs(color = "Cluster ID", title = "Spread of events in top clusters")
      ggsave(paste0(k, "-map.png"), event_map)


      # most common issue, most common racial issue, most common location
      common_issue <- events |>
        select(cluster_id, issue) |>
        unnest(cols = issue) |>
        drop_na() |>
        filter(issue != "_Not relevant") |>
        group_by(cluster_id, most_common_issue = issue) |>
        count() |>
        group_by(cluster_id) |>
        slice_max(order_by = n, n = 1, with_ties = FALSE) |>
        select(-n)
      racial_issue <- events |>
        select(cluster_id, racial_issue) |>
        unnest(cols = racial_issue) |>
        drop_na() |>
        filter(racial_issue != "_Not relevant") |>
        group_by(cluster_id, most_common_racial_issue = racial_issue) |>
        count() |>
        group_by(cluster_id) |>
        slice_max(order_by = n, n = 1, with_ties = FALSE) |>
        select(-n)

      common_location <- events |>
        group_by(cluster_id, most_common_location = location) |>
        count() |>
        group_by(cluster_id) |>
        slice_max(order_by = n, n = 1, with_ties = FALSE) |>
        select(-n)

      top_clusters |>
        mutate(k = k) |>
        rename(cluster_id = clusters) |>
        left_join(racial_issue, by = "cluster_id") |>
        left_join(common_issue, by = "cluster_id") |>
        left_join(common_location, by = "cluster_id")
    })
}
