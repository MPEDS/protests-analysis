get_mizzou_solidarity <- function(){
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  mpeds <- tar_read(integrated)

  mizzou_ids <- mpeds |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    pull(canonical_id)

  direct_links <- canonical_event_relationship |>
    filter(canonical_id2 == mizzou_ids) |>
    pull(canonical_id1)

  new_ids <- mizzou_ids
  should_find_events <- TRUE
  while(should_find_events){
    new_events <- tibble(canonical_id2 = new_ids) |>
      inner_join(canonical_event_relationship, by = c("canonical_id2"))
    new_ids <- new_events$canonical_id1
    mizzou_ids <- c(mizzou_ids, new_ids)
    if(length(new_ids) == 0){
      should_find_events <- FALSE
    }
  }

  mizzou_ids <- unique(mizzou_ids)

  mpeds |>
    filter(canonical_id %in% mizzou_ids,
           !str_detect(key, "^Umbrella")
           ) |>
    st_drop_geometry() |>
    mutate(direct_link = canonical_id %in% direct_links) |>
    select(key, university, direct_link)
}
