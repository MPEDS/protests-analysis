# A truly one-off investigation -- trying to find out how strange relationships were
# connected
get_tsitsi_timeline <- function(){
  con <- connect_sheriff()
  relationships <- tbl(con, "canonical_event_relationship") |>
    filter(canonical_id1 == 1385) |>
    mutate(record_type = "relationship") |>
    rename(canonical_id = canonical_id1)
  candidate_event <- tbl(con, "coder_event_creator") |>
    filter(coder_id == 55, timestamp >= "2022-04-23", timestamp <= "2022-04-25") |>
    mutate(record_type = "candidate_event")
  links <- tbl(con, "canonical_event_link") |>
    filter(coder_id == 55, timestamp >= "2022-04-23", timestamp <= "2022-04-25") |>
    mutate(record_type = "link")
  list(relationships, candidate_event, links) |>
    map(collect) |>
    bind_rows() |>
    select(-coder_id, -id, -text, -article_id) |>
    arrange(timestamp) |>
    rename(relationship_with = canonical_id2, candidate_event_id = event_id, candidate_record_id = cec_id) |>
    select(timestamp, record_type, everything())
}
