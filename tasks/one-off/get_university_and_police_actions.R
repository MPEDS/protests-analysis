# US only, Canada only, US + Canada

# University and Police Involvement

get_summary_count<- function() {
  # get_uni_police_responses() # from get_uni_police_responses.R

  tar_load(integrated)

  integrated <- integrated |>
    filter(!str_detect(tolower(key), "umbrella"))

  codes <- tribble(
    ~category, ~question,
    "Uni response", "university_reactions_to_protest",
    "Uni response", "university_discourse_on_protest",
    "Uni response", "university_action_on_issue",
    "Uni response", "university_discourse_on_issue",
    "Police action", "type_of_police",
    "Police action", "police_activities",
    "Police action", "police_presence_and_size",
    "Police action", "protester_resistance_to_police",
  )

    responses <- integrated |>
    st_drop_geometry() |>
    select(key, codes$question) |>
    mutate(across(c(where(is.character), -key), as.list)) |>
    pivot_longer(cols = c(everything(), -key), names_to = "question") |>
    unnest(value) |>
    filter(!is.na(value), value != "NA/Unclear") |>
    left_join(codes, by = "question")

    # Counts for canonical events with any value for each uni response question
    summary_counts <- responses |>
      group_by(question) |>
      summarize("Number of canonical events with valid response" = length(unique(key)))

    total_university_response_events <- responses |>
      filter(grepl("^university_", question)) |>
      summarize("Number of canonical events with valid response" = length(unique(key)),
                question = "Number of events with any university response coding")

    total_police_response_events <- responses |>
      filter(grepl("police", question)) |>
      summarize("Number of canonical events with valid response" = length(unique(key)),
                  question = "Number of events with any police coding")

    # Number of events with both any university response coding and any police coding
    total_university_or_police_events <- responses |>
      filter(grepl("police|^university_", question))  |>
      summarize("Number of canonical events with valid response" = length(unique(key)),
                question = "Number of events with both any university response coding and any police coding")

    # Number of events with neither a university response nor any police coding

    total_no_response <- tibble("Number of canonical events with valid response" = length(unique(integrated$key)) - length(unique(responses$key)),
                                question = "Number of events with neither university response nor police coding")

    # Total protest count
    total_protests <- tibble("Number of canonical events with valid response" = length(unique(integrated$canonical_id)),
                             question = "Total number of protests")

    # Put everything together
    summary_counts <- bind_rows(summary_counts, total_university_response_events,
                                total_police_response_events, total_university_or_police_events, total_no_response,
                                total_protests)


    # Individual response and action counts

    response_action_counts <- responses |>
      group_by(category, value) |>
      summarise(count = n()) |>
      mutate(percentage = count / length(unique(integrated$canonical_id)))

    total_protests_row <- tibble(category = NA, value = "Total number of protests", count = length(unique(integrated$canonical_id)))

    response_action_counts <- bind_rows(response_action_counts, total_protests_row)


    writexl::write_xlsx(lst(summary_counts, response_action_counts),
                        "docs/data-cleaning-requests/university_police_actions.xlsx")

}

