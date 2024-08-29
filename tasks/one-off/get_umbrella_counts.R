
get_umbrella_counts <- function() {

  integrated <- tar_read(integrated) |>
    mutate(canonical_id = as.integer(canonical_id))

  umbrellas <- integrated |>
    st_drop_geometry() |>
    filter(str_detect(tolower(key),"umbrella")) |>
    select(canonical_id,key)


  canonical_event_relationship <- tar_read(canonical_event_relationship)

  umbrellas_summary <- canonical_event_relationship |>
    select(canonical_id2) |>
    group_by(canonical_id2) |>
    summarise(number_events = n()) |>
    arrange(desc(number_events)) |>
    right_join(umbrellas, by = c("canonical_id2" = "canonical_id")) |>
    relocate(key) |>
    select(-canonical_id2)

}
