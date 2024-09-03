# Umbrella events and their relationships
get_umbrella <- function(){
  mpeds <- tar_read(integrated)
  mpeds <- mpeds |>
    st_drop_geometry() |>
    select(canonical_id, key) |>
    mutate(canonical_id = as.integer(canonical_id))
  umbrella <- mpeds |>
    filter(str_detect(key, "^Umbrella"))

  canonical_event_relationship <- tar_read(canonical_event_relationship)
  canonical_event_relationship <- canonical_event_relationship |>
    mutate(relationship_type = paste0("Has as ", relationship_type)) |>
    # switcheroo needed to avoid duplication in bind_rows
    rename(canonical_id1 = canonical_id2, canonical_id2 = canonical_id1) |>
    bind_rows(
      mutate(canonical_event_relationship,
             relationship_type = paste0(relationship_type, " event for"))
    ) |>
    right_join(umbrella, by = c("canonical_id1" = "canonical_id")) |>
    rename(umbrella_key = key) |>
    left_join(mpeds, by = c("canonical_id2" = "canonical_id")) |>
    select(-canonical_id1, -canonical_id2) |>
    group_by(relationship_type, umbrella_key) |>
    summarize(key = paste0(key, collapse = ", "),
              .groups = "drop") |>
    drop_na(relationship_type) |>
    pivot_wider(names_from = "relationship_type", values_from = "key")

  return(canonical_event_relationship)
}
