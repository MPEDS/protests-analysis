# Counts for uni responses and police actions
get_uni_police_responses <- function(){
  tar_load(integrated)
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

  # And a sheet with those keys, probably some info about them too
  response_keys <- integrated |>
    st_drop_geometry() |>
    select(key, location, description, issue, racial_issue, codes$question) |>
    filter(key %in% unique(responses$key)) |>
    mutate(across(c(issue, racial_issue), ~map_chr(., \(lst){
      lst |>
        str_subset("_Not relevant", negate = TRUE) |>
        paste0(collapse = ", ")})),
      across(c(codes$question, -where(is.list)), as.list)
    ) |>
    pivot_longer(codes$question, names_to = "question") |>
    unnest(value) |>
    filter(value != "NA/Unclear") |>
    group_by(question)
  response_keys <- group_split(response_keys) |>
    set_names(group_keys(response_keys)$question)

  # Counts for each response
  response_counts <- responses |>
    mutate(category = paste(category, "summary")) |>
    arrange(value) |>
    group_by(category, question, value) |>
    count(name = "Number of canonical events") |>
    group_by(category)
  # Split by type of question
  response_counts <- group_split(response_counts) |>
    set_names(group_keys(response_counts)$category) |>
    map(~select(., -category))

  c(
    lst(summary_counts),
    response_counts,
    response_keys
  )
}

get_addtl_info <- function(){
  tar_load(integrated)
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
    left_join(codes, by = "question") |>
    select(-question) |>
    unnest(value) |>
    drop_na(value) |>
    pivot_wider(names_from = category) |>
    mutate(response_type = map2_chr(`Police action`, `Uni response`, \(x,y){
      case_when(
      is.null(x) & is.null(y) ~ "neither",
      is.null(x) & !is.null(y) ~ "uni_response",
      !is.null(x) & is.null(y) ~ "police_action",
      !is.null(x) & !is.null(y) ~ "both",
      T ~ NA_character_
    )}))

  counts <- res

  # Counts for canonical events with any value for each uni response question
  summary_counts <- responses |>
    group_by(question) |>
    summarize("Number of canonical events with valid response" = length(unique(key)))

}
