# US only, Canada only, US + Canada

# University and Police Involvement

get_summary_count<- function(country = NULL) {

  tar_load(integrated)

  integrated <- integrated |>
    filter(!str_detect(tolower(key), "umbrella|virtual"))

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

    all_protests <- integrated |>
      mutate(location = case_when(
        location == "Ann Arbor, MI" ~ "Ann Arbor, MI, USA",
        location == "Montreal, QC, Quebec" ~ "Montreal, QC, Canada",
        T ~ location
      )) |>
      filter(!str_detect(str_to_lower(key), "delete"))

    responses <- all_protests

    if (!is.null(country)) {
      if(country == "USA") {
        responses <- all_protests |>
          filter(str_detect(str_to_lower(location), "(usa)|(us$)|(united states)"))
      }

      if(country == "Canada") {
        responses <- all_protests |>
          filter(str_detect(str_to_lower(location), "(canada)|(, ca$)|(, can$)"))
      }
    }

    responses <- responses |>
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

    total_no_response <- tibble("Number of canonical events with valid response" = length(unique(all_protests$key)) - length(unique(responses$key)),
                                question = "Number of events with neither university response nor police coding")

    # Total protest count variables depending on country selection. Used twice
    if (!is.null(country)) {
      total_protest_count <- length(unique(responses$key))
      total_protest_string <- paste0("Total number of protests in ", country)
    } else {
      total_protest_count <- length(unique(all_protests$key))
      total_protest_string <- "Total number of protests"
    }

    # Total protest count sheet 1
    total_protests <- tibble("Number of canonical events with valid response" = total_protest_count,
                             question = total_protest_string)

    # Put everything together
    summary_counts <- bind_rows(summary_counts, total_university_response_events,
                                total_police_response_events, total_university_or_police_events, total_no_response,
                                total_protests)


    # Individual response and action counts
    response_action_counts <- responses |>
      group_by(category, question, value) |>
      summarise(count = n()) |>
      mutate(percentage = count / length(unique(all_protests$canonical_id)))

    # Sheet 2, should be renamed
    total_protests_row <- tibble(category = NA, value = total_protest_string,
                                 count = total_protest_count)

    response_action_counts <- bind_rows(response_action_counts, total_protests_row)

    # any_police_action_count <- responses |>
    #   filter(category == "Police action") |>
    #   tibble(category = NA, value = "Total number of protests with any police action",
    #          count = length(unique(key)))


    # Output

    file_end <- ifelse(is.null(country), "no_virtual", country)
    writexl::write_xlsx(lst(summary_counts, response_action_counts),
                        paste0("docs/data-cleaning-requests/university_police_actions_", file_end, ".xlsx"))


}

get_all_summary_counts <- function() {
  get_summary_count()
  get_summary_count("USA")
  get_summary_count("Canada")
}
