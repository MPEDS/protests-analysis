get_mizzou_coverage <- function(){
  # get article and newspaper counts for
  # “university action on issue” = resign/fire and start date = 2015-11-09
  # resign/fire + start date = 2015-11 + location = Columbia, MO)
  canonical_events <- tar_read(canonical_events)
  articles <- get_articles(canonical_events)
  articles <- select(articles, article_id, publication) |> distinct()
  con <- connect_sheriff()
  candidate_events <- tbl(con, "coder_event_creator") |>
    collect()

  coverage <- candidate_events |>
    filter(variable %in% c("start-date", "university-action-on-issue")) |>
    select(article_id, event_id, coder_id, variable, value) |>
    pivot_wider(names_from = variable, values_from = value) |>
    filter(
      map_lgl(`university-action-on-issue`, ~"Resign/Fire" %in% .),
      map_lgl(`start-date`, ~any(str_detect(., "^2015-11"))),
    ) |>
    left_join(articles, by = "article_id")


}
