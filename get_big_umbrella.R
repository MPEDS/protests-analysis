# Would you be able to generate a spreadsheet like this one  for but for all uni responses?
# The one caveat though is that I only want uni responses to events that belong
# to an umbrella that have 2 or more events. Would that even be possible?

get_big_umbrella <- function() {

  # get umbrella events
  mpeds <- tar_read(integrated) |>
    mutate(canonical_id = as.integer(canonical_id))

  umbrella <- mpeds |>
    st_drop_geometry() |>
    filter(str_detect(key, "^Umbrella")) |>
    select(canonical_id, key)

  # get event relationships, for two reasons
  #    1. only interested in umbrellas with 2+ events
  #    2. need to pull the kind of relationship
  canonical_event_relationship <- tar_read(canonical_event_relationship)

  relevant_umbrellas <- canonical_event_relationship |>
    group_by(canonical_id1, canonical_id2) |>
    summarize(relationship_type = paste0(relationship_type, collapse = ", ")) |>
    right_join(umbrella, by = c("canonical_id2" = "canonical_id")) |>
    group_by(key) |>
    filter(n() > 1) |>
    rename(umbrella_key = key)

  responses <- mpeds |>
    st_drop_geometry() |>
    right_join(relevant_umbrellas, by = c("canonical_id" = "canonical_id1")) |>
    select(key,
           umbrella_key,
           relationship_type,
           start_date,
           description, university_responses_text,
           university_reactions_to_protest, university_discourse_on_protest,
           university_action_on_issue, university_discourse_on_issue,
           ) |>
    mutate(across(where(is.list), ~map_chr(., ~paste0(.[. != "NA/Unclear"], collapse = ", "))))

  writexl::write_xlsx(responses,
                      "docs/data_cleaning_requests/all_umbrella_uni_responses.xlsx")

}
