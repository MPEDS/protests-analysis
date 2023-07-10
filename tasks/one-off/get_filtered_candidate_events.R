# Often I want to attach candidate events to canonical events to see what
# candidate events might need investigation
get_filtered_candidate_events <- function(){
  con <- connect_sheriff()
  uncodable_ids <- tbl(con, "coder_event_creator") |>
    filter(
      variable %in% c("no-protest", "non-campus",
                      "non-us", "historical",
                      "vague-event","duplicate")
    ) |>
    collect() |>
    pull(event_id) |>
    unique()
  event_metadata <- tbl(con, "event_metadata") |>
    collect() |>
    filter(!str_detect(coder_id, "^UR_|^PA_"),
           !(event_id %in% uncodable_ids)) |>
    select(event_id)

  canonical_event_link <- tbl(con, "canonical_event_link") |>
    group_by(canonical_id) |>
    collect() |>
    right_join(event_metadata, by = c("cec_id" = "event_id")) |>
    summarize(candidate_ids = str_flatten(cec_id, collapse = ", "))

  return(canonical_event_link)
}
