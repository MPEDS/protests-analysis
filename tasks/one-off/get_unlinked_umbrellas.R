get_unlinked_umbrellas <- function(){
  con <- connect_sheriff()
  coders <- tbl(con, "user") |>
    select(id, username) |>
    collect()

  umbrella_ids <- tar_read(canonical_event_relationship) |>
    filter(relationship_type == "campaign") |>
    pull(canonical_id2) |>
    unique()

  unlinked_umbrellas <- integrated |>
    st_drop_geometry() |>
    filter(str_detect(key, "Umbrella"), !(canonical_id %in% umbrella_ids)) |>
    select(canonical_id, key, adjudicator_id, description) |>
    left_join(coders, by = c("adjudicator_id" = "id"))

  return(unlinked_umbrellas)
}
