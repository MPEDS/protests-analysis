get_canonical_event_relationship <- function(dummy_tbl){
  con <- connect_sheriff()

  canonical_event_relationship <- tbl(con, "canonical_event_relationship") |>
    select(canonical_id1, canonical_id2, relationship_type) |>
    collect()

  return(canonical_event_relationship)
}
