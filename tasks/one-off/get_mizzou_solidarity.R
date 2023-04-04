get_mizzou_solidarity <- function(){
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  mpeds <- tar_read(integrated)

  mizzou_umbrella_id <- mpeds |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    pull(canonical_id)

  mizzou_events <- canonical_event_relationship |>
    filter(canonical_id2 == mizzou_umbrella_id,
           relationship_type %in% c("campaign", "solidarity")) |>
    pull(canonical_id1)

  mpeds |>
    filter(canonical_id %in% mizzou_events) |>
    select(canonical_id, canonical_key = key, university) |>
    st_drop_geometry()
}
