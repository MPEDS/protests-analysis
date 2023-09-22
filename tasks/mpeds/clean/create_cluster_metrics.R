create_cluster_metrics <- function(clusters, cluster_inputs, cleaned_events,
                                   canonical_event_relationship){
  # One plot per metric to compare many Ks on one plot
  metric_plots <- clusters |>
    pivot_longer(cols = c(swap_objective, avg_separation, avg_dissimilarity)) |>
    group_split(name) |>
    map(\(group_dta){
      metric <- unique(group_dta$name)
      metric_label <- str_split_1(metric, pattern = "_") |>
        str_to_title() |>
        paste(collapse = " ")
      metric_plot <- group_dta |>
        ggplot(aes(x = k, y = value)) +
        geom_point() +
        labs(
          title = metric_label,
          y = metric_label,
          x = "Number of clusters"
        )
      list(metric_plot) |> set_names(metric_label)
    }) |>
    flatten()

  profiles <- clusters |>
    group_split(k) |>
    map_dfr(\(clustering){
      k <- unique(clustering$k)

      top_clusters <- clustering |>
        unnest(clusters) |>
        count(clusters) |>
        ungroup() |>
        slice_max(order_by = n, n = 5)

      events <- cluster_inputs |>
        select(key) |>
        mutate(cluster_id = unlist(clustering$clusters)) |>
        left_join(cleaned_events, by = "key") |>
        filter(cluster_id %in% top_clusters$clusters)

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

      event_glance <- events |>
        select(key, cluster_id) |>
        arrange(key) |>
        group_by(cluster_id) |>
        summarize(keys = paste(key, collapse = ", "))

      top_clusters |>
        mutate(k = k) |>
        rename(cluster_id = clusters) |>
        left_join(racial_issue, by = "cluster_id") |>
        left_join(common_issue, by = "cluster_id") |>
        left_join(common_location, by = "cluster_id") |>
        left_join(event_glance, by = "cluster_id")
    })

  return(lst(
    metric_plots, profiles
  ))
}
