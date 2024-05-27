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

  is_all_na <- function(x){all(is.na(x))}

  responses <- integrated |>
    st_drop_geometry() |>
    filter(!str_detect(key, "Umbrella")) |>
    select(key, codes$question) |>
    mutate(across(c(where(is.character), -key), as.list)) |>
    pivot_longer(cols = c(everything(), -key), names_to = "question") |>
    left_join(codes, by = "question") |>
    select(-question) |>
    unnest(value, keep_empty = TRUE) |>
    mutate(value = ifelse(value == "NA/Unclear", NA_character_, value)) |>
    distinct() |>
    pivot_wider(names_from = category, values_fn = list) |>
    mutate(response_type = map2_chr(`Police action`, `Uni response`, \(x,y){
      case_when(
      !is_all_na(x) & !is_all_na(y) ~ "both",
      is_all_na(x) & is_all_na(y) ~ "neither",
      is_all_na(x) & !is_all_na(y) ~ "uni_response",
      !is_all_na(x) & is_all_na(y) ~ "police_action",
      T ~ NA_character_
    )}))

  counts <- responses |>
    group_by(response_type) |>
    count()

  key_info <- integrated |>
    st_drop_geometry() |>
    filter(!str_detect(key, "Umbrella")) |>
    left_join(select(responses, key, response_type), by = "key") |>
    select(key, location, description, start_date, form, issue, racial_issue, response_type, codes$question) |>
    mutate(across(where(is.list), ~map_chr(., \(lst){
      lst |>
        str_subset("(_Not relevant)|(NA/Unclear)", negate = TRUE) |>
        paste0(collapse = ", ")})),
    ) |>
    group_by(response_type)

  key_info |>
    group_split() |>
    set_names(group_keys(key_info)$response_type) |>
    map(\(dta){select(dta, -response_type)})

  writexl::write_xlsx(lst(responses, summary_counts, key_info),
                      "docs/data-cleaning-requests/test.xlsx")
}
