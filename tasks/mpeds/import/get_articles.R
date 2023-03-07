get_articles <- function(){
  con <- connect_sheriff()

  articles_db <- tbl(con, "article_metadata")
  coder_event_creator <- tbl(con, "coder_event_creator") |>
    select(article_id, event_id) |>
    distinct()
  canonical_events <- tar_read(canonical_events) |>
    select(event_id, canonical_key = key) |>
    distinct()

  articles <- articles_db |>
    left_join(coder_event_creator, by = c("id" = "article_id")) |>
    collect() |>
    drop_na(event_id) |>
    # The canonical keys are just going to be used as reference when
    # glancing over tf-idf results, not for substantive grouping, so
    # it's fine to throw out multiple matches for now (so that analysis is still
    # run on each article only once)
    group_by(event_id) |>
    slice_head(n = 1) |>
    ungroup() |>
    left_join(canonical_events, by = "event_id") |>
    select(canonical_key, title, text) |>
    distinct()

  return(articles)
}
