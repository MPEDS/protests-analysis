# get all events under an umbrella

get_any_umbrella <- function(umbrella_event_key){

  mpeds <- tar_read(integrated)
  integrated <- mpeds |>
    st_drop_geometry() |>
    select(canonical_id, key)

  umbrella_event_id <- integrated |>
    filter(key == umbrella_event_key) |>
    pull(canonical_id)

  canonical_event_relationship <- tar_read(canonical_event_relationship)

  umbrella_relationships <- canonical_event_relationship |>
    filter(canonical_id2 == umbrella_event_id) |>
    mutate(canonical_id1 = as.character(canonical_id1))

  all_umbrella_events <- umbrella_relationships |>
    left_join(mpeds, by = c("canonical_id1" = "canonical_id")) |>
    select(!canonical_id2)

}
