get_articles <- function(){
  con <- connect_sheriff()

  articles_db <- tbl(con, "article_metadata")
  coder_event_creator <- tbl(con, "coder_event_creator") |>
    select(cec_id = id, article_id, event_id, variable) |>
    distinct()
  canonical_event_link <- tbl(con, "canonical_event_link") |>
    select(canonical_id, cec_id) |>
    distinct()
  canonical_events <- tbl(con, "canonical_event") |>
    select(key, canonical_id = id)

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
