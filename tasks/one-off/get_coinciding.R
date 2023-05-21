get_coinciding <- function(){
  mpeds <- tar_read(integrated) |> st_drop_geometry()

  keys <- mpeds |>
    select(key, canonical_id)

  rels <- tar_read(canonical_event_relationship) |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    rename(canonical_key = key) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id"))

  coinciding <- rels |>
    filter(relationship_type == "coinciding") |>
    select(coinciding_umbrella = key, canonical_key)

  solidarity <- rels |>
    filter(relationship_type == "solidarity") |>
    select(solidarity_with = key, canonical_key) |>
    group_by(canonical_key) |>
    summarize(solidarity_with = paste0(solidarity_with, collapse = ", ")) |>
    mutate(is_solidarity = TRUE)

  mpeds |>
    right_join(coinciding, by = c("key" = "canonical_key")) |>
    left_join(solidarity, by = c("key" = "canonical_key")) |>
    select(key, description, start_date, issue,
           racial_issue, coinciding_umbrella,
           is_solidarity, solidarity_with
           ) |>
    mutate(across(c(issue, racial_issue),
                  ~map_chr(., function(x){paste0(x, collapse = ", ")}))
           )
}
