get_uc_berkeley <- function(){
  tar_load(integrated)
  tar_load(canonical_event_relationship)

  # Transform relationship into keys
  keys <- select(st_drop_geometry(integrated), canonical_id, key)

  rels <- canonical_event_relationship |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    select(canonical_key1 = key, canonical_id2, relationship_type) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(canonical_key1, canonical_key2 = key, relationship_type) |>
    pivot_wider(
      names_from = relationship_type,
      values_from = canonical_key2,
      values_fn = ~paste0(., collapse = ", ")
      )

  integrated |>
    st_drop_geometry() |>
    nest_filter(university, uni_id == "110635") |>
    filter(map_lgl(university, ~nrow(.) != 0)) |>
    select(
      key,
      description,
      publication,
      start_date,
      end_date, location,
      form, issue,
      racial_issue,
      police_activities,
      police_presence_and_size,
      university_reactions_to_protest,
      university_action_on_issue,
      university_discourse_on_protest,
      university_discourse_on_issue
    ) |>
    mutate(across(where(is.list), ~map_chr(., ~paste0(.[. != "_Not relevant"], collapse = ", ")))) |>
    left_join(rels, by = c("key" = "canonical_key1"))
}
