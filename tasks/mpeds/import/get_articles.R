get_articles <- function(canonical_events){
  con <- connect_sheriff()

  articles_db <- tbl(con, "article_metadata")
  coder_event_creator <- tbl(con, "coder_event_creator") |>
    select(article_id, event_id) |>
    distinct()
  canonical_events <- canonical_events |>
    select(event_id, canonical_key = key) |>
    distinct()

  articles <- articles_db |>
    left_join(coder_event_creator, by = c("id" = "article_id")) |>
    collect() |>
    drop_na(event_id) |>
    left_join(canonical_events, by = "event_id") |>
    drop_na(canonical_key) |>
    select(canonical_key, title, article_id = id, publication, text) |>
    distinct()

  return(articles)
}
