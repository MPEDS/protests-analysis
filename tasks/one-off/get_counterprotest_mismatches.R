get_counterprotest_mismatch <- function(){
  tar_load(canonical_event_relationship)
  tar_load(integrated)

  keys <- integrated |>
    select(key, canonical_id) |>
    mutate(canonical_id = as.integer(canonical_id))

  counterprotest_rels <- canonical_event_relationship |>
    filter(relationship_type == "counterprotest")  |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    select(counterprotest_event = key,
           canonical_id2,
           ) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(counterprotest_event, original_event = key) |>
    mutate(is_counterprotest = TRUE)

  # Here canonical_id1 seems to indicate the counterprotesting event

  integrated |>
    st_drop_geometry() |>
    mutate(canonical_id = as.integer(canonical_id)) |>
    select(key, counterprotest_checkbox = counterprotest,
           description, location, issue, racial_issue) |>
    left_join(counterprotest_rels, by = c("key" = "counterprotest_event")) |>
    filter(
      (!is.na(is_counterprotest) & !counterprotest_checkbox) |
      (is.na(is_counterprotest) & counterprotest_checkbox)
      ) |>
    mutate(across(
      where(is.list),
      ~map_chr(., ~paste0(.[!(. == "_Not relevant")], collapse = ", "))
      ),
      is_counterprotest = ifelse(is.na(is_counterprotest), FALSE, is_counterprotest)
      ) |>
    rename(is_counterprotest_relationship = is_counterprotest,
           is_counterprotest_checkbox = counterprotest_checkbox) |>
    arrange(is_counterprotest_relationship, is_counterprotest_checkbox) |>
    select(key, starts_with("is_"), everything())
}
