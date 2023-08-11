get_mizzou_solidarity <- function(){
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  mpeds <- tar_read(integrated)

  con <- connect_sheriff()

  canonical_events <- tbl(con, "canonical_event") |>
    collect()
  mizzou_ids <- canonical_events |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    select(canonical_id1 = id) |>
    mutate(relationship_type = "Mizzou event")
  direct_links <- canonical_event_relationship |>
    filter(canonical_id2 %in% mizzou_ids$canonical_id1, relationship_type != "counterprotest") |>
    distinct()
  mizzou_ids <- bind_rows(mizzou_ids, direct_links)
  new_events <- direct_links
  should_find_events <- TRUE
  while(should_find_events){
    new_events <- new_events |>
      select(canonical_id2 = canonical_id1) |>
      inner_join(canonical_event_relationship, by = "canonical_id2",
                 relationship = "many-to-many") |>
      filter(relationship_type != "counterprotest")
    mizzou_ids <- bind_rows(mizzou_ids, new_events) |> distinct()
    if(nrow(new_events) == 0){
      should_find_events <- FALSE
    }
  }

  keys <- canonical_events |>
    select(relationship_with =key, id) |>
    distinct()

  canonical_events |>
    right_join(mizzou_ids, by = c("id" = "canonical_id1")) |>
    left_join(keys, by = c("canonical_id2" = "id")) |>
    select(-id, -coder_id, -notes, -last_updated)
}

get_mizzou_schools <- function(){
  mizzou_id <- 26
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  mizzou_solidarity <- canonical_event_relationship |>
    filter(relationship_type == "solidarity", canonical_id2 == 26) |>
    pull(canonical_id1)
  mpeds <- tar_read(integrated) |>
    st_drop_geometry() |>
    filter(canonical_id %in% mizzou_solidarity)

  participating_universities <- mpeds |>
    select(key, participating_universities_text) |>
    unnest(participating_universities_text) |>
    rename(university = participating_universities_text) |>
    mutate(uni_name_source = "Other participating universities")

  universities <- mpeds |>
    select(key, university, uni_name_source) |>
    bind_rows(participating_universities)
}
