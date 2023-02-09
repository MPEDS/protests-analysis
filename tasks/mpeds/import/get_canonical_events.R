get_canonical_events <- function(){
  con <- connect_sheriff()
  # Merging:
  # `article_metadata`: Provides publication name so we can
  #   create some auxiliary or backup location variables
  # `coder_event_creator`: dataset of candidate events, or events
  # gleaned from articles pre-creation of canonical events
  # `canonical_event_link`: A crosswalk of which properties in the
  #   above dataset correspond to canonical events
  # `canonical_event`: Data containing canonical events, which
  # are made from the combined properties of candidate events

  # Must attach canonical event ID in advance, for now
  # attaching it to the location because
  # articles aren't attached by coders
  article_metadata <- tbl(con, "article_metadata") |>
    select(article_id = id, publication) |>
    mutate(variable = "location") |>
    left_join(tbl(con, "coder_event_creator"),
               by = c("article_id", "variable")) |>
    filter(variable == "location") |>
    select(publication, cec_id = id) |>
    filter(!is.na(cec_id)) |>
    inner_join(tbl(con, "canonical_event_link"), by = "cec_id") |>
    select(-timestamp, -cec_id, -id, -coder_id) |>
    distinct()

  canonical_events <- tbl(con, "coder_event_creator") |>
    select(-coder_id, -timestamp, -article_id) |>
    rename(cec_id = id) |>
    right_join(tbl(con, "canonical_event_link"), by = "cec_id") |>
    select(-coder_id, -id) |>
    right_join(tbl(con, "canonical_event"),
               by = c("canonical_id" = "id")) |>
    select(-last_updated, -coder_id, -timestamp) |>
    left_join(article_metadata, by = "canonical_id") |>
    collect()

  return(canonical_events)
}
