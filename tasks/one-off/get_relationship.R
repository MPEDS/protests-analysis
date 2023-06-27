get_relationship <- function(relationship){
  name_string <- rlang::as_name(enquo(relationship))
  mpeds <- tar_read(integrated) |> st_drop_geometry()

  keys <- mpeds |>
    select(key, canonical_id)

  # Translate relationship xwalk from operating by IDs to keys
  rels <- tar_read(canonical_event_relationship) |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    rename(canonical_key = key) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id"))

  # Isolate specific relationship of interest
  rel <- rels |>
    filter(relationship_type == name_string) |>
    select(key, canonical_key) |>
    group_by(canonical_key) |>
    summarize("{{relationship}}" := paste0(key, collapse = ", "))

  mpeds |>
    select(key, description, start_date, issue, racial_issue) |>
    right_join(rel, by = c("key" = "canonical_key")) |>
    mutate(across(c(issue, racial_issue),
                  ~map_chr(., function(x){paste0(x, collapse = ", ")}))
           )
}


