# Pulling some keys for analysis
get_uni_keys <- function(){
  # Univ Reactions to Protest = Penalize, End Protest
  # Univ Action on Issue = Fulfill Demand, Resign/Fire, Cancel Speaker/Event, No Cancellation
  # Univ Discourse on Issue = Apology/Responsibility
  mpeds <- tar_read(integrated) |>
    st_drop_geometry()

  keys <- mpeds |>
    select(canonical_id, key) |>
    distinct()

  canonical_event_relationship <- tar_read(canonical_event_relationship)
  canonical_event_relationship <- canonical_event_relationship |>
    mutate(relationship_type = paste0("Has as ", relationship_type)) |>
    rename(canonical_id1 = canonical_id2, canonical_id2 = canonical_id1) |>
    bind_rows(
      mutate(canonical_event_relationship,
             relationship_type = paste0(relationship_type, " event for"))
    ) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    rename(related_keys = key) |>
    select(-canonical_id2)

  # Named list of tibbles, to be output as .xlsx
  mpeds_lst <- mpeds |>
    mutate(
      is_penalize = map_lgl(university_reactions_to_protest,
                            ~("Penalize" %in% .)),
      is_end_protest = map_lgl(university_reactions_to_protest,
                            ~("End Protest" %in% .)),
      is_fulfill_demand = map_lgl(university_action_on_issue,
                            ~("Fulfill Demand" %in% .)),
      is_resign_fire = map_lgl(university_action_on_issue,
                            ~("Resign/Fire" %in% .)),
      is_cancel_event = map_lgl(university_action_on_issue,
                            ~("Cancel Speaker/Event" %in% .)),
      is_no_cancellation = map_lgl(university_action_on_issue,
                            ~("No Cancellation" %in% .)),
      is_apology = map_lgl(university_discourse_on_issue,
                            ~("Apology/Responsibility" %in% .)),
    ) |>
    select(canonical_id, key, starts_with("is_")) |>
    left_join(
      canonical_event_relationship, by = c("canonical_id" = "canonical_id1"),
      multiple = "all"
    ) |>
    pivot_longer(cols = starts_with("is_")) |>
    filter(value) |>
    select(-value, -canonical_id) |>
    mutate(related_keys = ifelse(is.na(related_keys), "", related_keys)) |>
    group_by(key, relationship_type, name) |>
    summarize(related_keys = paste0(related_keys, collapse = ", "),
              .groups = "drop") |>
    # Can't think of better way to get named list of tbls
    group_by(name) |>
    group_map(~list(.x) |> set_names(.y)) |>
    flatten()

}
