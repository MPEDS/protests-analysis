get_articles <- function(){
  con <- connect_sheriff()

  coder_event_creator <- tbl(con, "coder_event_creator") |>
    select(cec_id = id, article_id, event_id) |>
    distinct()

  canonical_event_link <- tbl(con, "canonical_event_link") |>
    select(canonical_id, cec_id) |>
    left_join(coder_event_creator, by = "cec_id") |>
    select(event_id, canonical_id, article_id) |>
    distinct()

  canonical_events <- tbl(con, "canonical_event") |>
    select(canonical_key = key, canonical_id = id) |>
    left_join(canonical_event_link, by = "canonical_id")

  articles <- canonical_events |>
    left_join(tbl(con, "article_metadata"), by = c("article_id" = "id")) |>
    collect() |>
    drop_na(event_id, canonical_key) |>
    select(canonical_key, title, article_id, publication, text) |>
    mutate(canonical_key = str_trim(canonical_key)) |>
    distinct()

  return(articles)
}
