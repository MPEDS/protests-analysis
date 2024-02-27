get_unnamed_umbrellas <- function(){
  # Get all events that are campaign or solidarity parents but not called "^Umbrella.*"
  # and which do not themselves have an umbrella event
  keys <- integrated |>
    select(canonical_id, key)
  rels <- canonical_event_relationship |>
    mutate(across(where(is.integer), as.character)) |>
    filter(relationship_type != "counterprotest") |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(lead = key, canonical_id1, relationship_type) |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    select(lead, sub_event = key, relationship_type)

  rels |>
    filter(map_lgl(lead, ~!(. %in% rels$sub_event)),
           !str_detect(lead, "^Umbrella")) |>
    group_by(lead) |>
    summarize(
      n_occurrences = n(),
      types = paste0(unique(relationship_type), collapse = ", ")
    ) |>
    arrange(desc(n_occurrences))
}
