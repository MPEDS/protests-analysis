assign_issue_clusters <- function(distance_matrix, k){
  start <- Sys.time()

  clusters <- pam(distance_matrix, k = k, diss = TRUE, variant = "faster")
  clusinfo <- as.data.frame(clusters$clusinfo)

  return(tibble(
    k,
    swap_objective = clusters$objective[2],
    avg_separation = mean(clusinfo$separation),
    avg_dissimilarity = mean(clusinfo$av_diss),
    time = Sys.time() - start,
    silhouette_width = clusters$silinfo$avg.width,
    clusters = list(clusters$clustering),
  ))
}

