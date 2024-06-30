# simple script to get basic counts of canonical events

get_canonical_counts <- function() {
  canonical_events <- tbl(con, "canonical_event") |>
    filter(!str_detect(key, "^Umbrella")) |>
    # select(id, key) |>
    collect()
    # mutate(is_in_canonical_event = TRUE)

  integrated <- tar_read(integrated) |>
    st_drop_geometry() |>
    filter(!str_detect(tolower(key), "umbrella"))

  combined <- integrated |>
    mutate(is_in_integrated = TRUE) |>
    full_join(canonical_events) |>
    mutate(across(where(is.logical), ~ifelse(is.na(.), FALSE, .)))

  combined_ids <- integrated |>
    mutate(is_in_integrated = TRUE,
           canonical_id = as.integer(canonical_id)) |>
    full_join(canonical_events, by = c("canonical_id" = "id")) |>
    mutate(across(where(is.logical), ~ifelse(is.na(.), FALSE, .))) |>
    select(-contains("key"))

  # yields "14", "15", "16", "24","28"
  # not_in_canonical <- setdiff(integrated$canonical_id, canonical_events$id)

  in_integrated_only <- integrated |>
    filter(canonical_id %in% c("14", "15", "16", "24","28"))

  in_canonical_events_only <- canonical_events |>
    filter(id %in% c("647"))

  cleaned_events <- tar_read(cleaned_events) |>
    filter(!str_detect(tolower(key), "umbrella"))

  events_wide <- tar_read(events_wide) |>
    filter(!str_detect(tolower(key), "umbrella"))

  canonical_events_target <- tar_read(canonical_events) |>
    filter(!str_detect(tolower(key), "umbrella")) |>
    select(key)
}
