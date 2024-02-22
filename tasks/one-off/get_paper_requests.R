# A crosstab or heatmap of cooccurring issues. We want to see what seems to hang
#   together for events. We’d also like to see the same for form and target, as well as the top 15 forms and targets with percentage.
get_paper_requests <- function(){
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
  all_protests_n <- integrated |>
    filter(!str_detect(key, "Umbrella")) |>
    nrow()

  # Percentage of protests which have any university response; then top 15 university
  #   reactions and university discourses, with percentage.
  any_uni_response <- integrated |>
    st_drop_geometry() |>
    select(key, filter(codes, category == "Uni response")$question) |>
    pivot_longer(cols = c(everything(), -key)) |>
    unnest(cols = c(value)) |>
    filter(value != "NA/Unclear")
  top_15_uni <- any_uni_response |>
    filter(name %in% c("university_reactions_to_protest",
                           "university_discourse_on_protest",
                            "university_action_on_issue",
                           "university_discourse_on_issue")) |>
    group_split(name) |>
    map(\(group_dta){
      group_val <- unique(group_dta$name)
      group_dta |>
        group_by(value) |>
        summarize(
          pct_events = 100 * length(unique(key))/all_protests_n,
          pct_responses = 100*n()/nrow(group_dta),
        ) |>
        ungroup() |>
        arrange(desc(pct_responses)) |>
        slice_max(order_by = pct_responses, n = 15) |>
        list() |>
        set_names(group_val)
    }) |>
    flatten()

  # Percentage of protests which have any police action; then the top 15 police actions
  #   which were taken, with percentage.
  any_police_action <- integrated |>
    select(key, filter(codes, category == "Police action")$question) |>
    mutate(across(c(where(is.character), -key), as.list)) |>
    st_drop_geometry() |>
    pivot_longer(cols = c(everything(), -key)) |>
    unnest(cols = c(value)) |>
    filter(value != "NA/Unclear")
  top_15_actions <- any_police_action |>
    filter(
      name %in% c(
        "type_of_police",
        "police_activities",
        "police_presence_and_size",
        "protester_resistance_to_police"
      )
    ) |>
    group_split(name) |>
    map(\(group_dta){
      group_val <- unique(group_dta$name)
      group_dta |>
        group_by(value) |>
        summarize(
          pct_events = 100 * length(unique(key))/all_protests_n,
          pct_responses = 100*n()/nrow(group_dta),
        ) |>
        ungroup() |>
        arrange(desc(pct_responses)) |>
        slice_max(order_by = pct_responses, n = 15) |>
        list() |>
        set_names(group_val)
    }) |>
    flatten()

  # If you have time, we could also use a list of the protests which have Trump as an
  #   issue that have counter protests. I think I can generate this from the SQL easy,
  #   but I know you may have some pipeline written for that already.
  tar_load(canonical_event_relationship)
  keys <- select(integrated, canonical_id, key) |>
    st_drop_geometry() |>
    mutate(canonical_id = as.integer(canonical_id))
  counter <- canonical_event_relationship |>
    filter(relationship_type == "counterprotest") |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    rename(key1 = key) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    rename(key2 = key) |>
    select(key1, key2)
  counter <- counter |>
    bind_rows(select(counter, key2 = key1, key1 = key2)) |>
    distinct() |>
    group_by(key = key1) |>
    summarize(counterprotest = paste0(key2, collapse = ", "))

  trump_counterprotests <- integrated |>
    select(-counterprotest) |>
    mutate(canonical_id = as.integer(canonical_id)) |>
    st_drop_geometry() |>
    filter(map_lgl(issue, ~any(str_detect(., "Trump")))) |>
    inner_join(counter, by = "key")  |>
    select(key, description, counterprotest, start_date,
           location, form, issue, racial_issue, issues_text,
           target, target_text, government_officials_text) |>
    mutate(across(where(is.list), ~map_chr(., \(x){paste0(sort(x), collapse = ", ")})),
           trump_issue = ifelse(map_lgl(issue, ~any(str_detect(., "Trump.*Against"))),
                                "Against Trump",
                                "For Trump"
                                )
             ) |>
    select(key, counterprotest, trump_issue, everything()) |>
    arrange(trump_issue, start_date)

  # 5. The % of protests that occur entirely off-campus on a higher ed issue (this is a
  #   checkbox question in the protocol).
  off_campus_higher_ed <- integrated |>
    st_drop_geometry() |>
    select(key, off_campus, issue) |>
    unnest(cols = c(issue)) |>
    filter(
      off_campus,
    ) |>
    select(-off_campus) |>
    group_by(key) |>
    summarize(issue = paste0(issue, collapse = "; "))
  list(
    top_15_uni,
    top_15_actions,
    list(trump_counterprotests = trump_counterprotests),
    list(off_campus_higher_ed = off_campus_higher_ed)
  ) |>
    flatten()
}
