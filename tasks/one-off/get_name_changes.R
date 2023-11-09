#  Identify any such canonical events - presumably by searching the event descriptions
# and/or issue text selects for related terms (name, named, naming, chang* not sure what else) and
# generate a sheet of those canonical events with key information on each event, including the event desc,
# issue text selects,  whether the event has any relationships (campaign, coinciding, solidarity), if
# there’s a Univ Response on Issue: Correct Racist History and, if so, the Univ Response text selects.
# It’s a little tricky because the search will probably pick up protests where naming is important in
# different ways such as commemoration, e.g. #SayHerName, reading the names of BIPOC people murdered by
# police, etc.

# 2) Search for canonical events that don’t have such a protest but
# do have a Univ Response on Issue: Correct Racist History and provide key information
# on each of events, including Univ Response text selects? (Those might help us identify
# any additional search terms, too).
get_name_changes <- function(){
  tar_load(integrated)
  keys <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key) |>
    distinct() |>
    drop_na()

  con <- connect_sheriff()
  relationships <- tbl(con, "canonical_event_relationship") |>
    select(canonical_id = canonical_id1, canonical_id2, relationship_type) |>
    collect() |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(-canonical_id2) |>
    mutate(relationship_type = paste0(relationship_type, "_with")) |>
    pivot_wider(names_from = relationship_type, values_from = key,
                values_fn = ~paste0(., collapse = ", "))

  cleaned_events <- integrated |>
    st_drop_geometry() |>
    left_join(relationships, by = "canonical_id") |>
    mutate(is_correct_racist_history = map_lgl(university_action_on_issue,
                                               ~"Correct Racist History" %in% .),
           uni_response_text_select = ifelse(is_correct_racist_history,
                                             university_responses_text,
                                             ""
                                             ) |>
             map_chr(~paste0(., collapse = "\n\n"))
           ) |>
    select(key, description, university, location, start_date,
           issue, racial_issue, issues_text,
           counterprotest_with, solidarity_with, coinciding_with,
           is_correct_racist_history, uni_response_text_select,
           university_action_on_issue, university_reactions_to_protest,
           university_discourse_on_issue, university_discourse_on_protest
           ) |>
    mutate(across(c(issue, racial_issue,
                    university_action_on_issue, university_discourse_on_issue,
                    university_reactions_to_protest, university_discourse_on_protest),
                  ~map_chr(., \(x){paste0(x, collapse = ", ")})),
           issues_text = map_chr(issues_text, ~paste0(., collapse = "\n\n"))) |>
    arrange(start_date)

  name_protests <- cleaned_events |>
    filter(
      # Match name but not SayHerName/Say Her Name, "named", "unnamed", or "namely"
      str_detect(str_to_lower(description), "(?<!sayher|say her |un)name(?!ly|d)") |
        str_detect(description, "naming") |
        str_detect(description, "renam")
    )

  correct_racist_history <- cleaned_events |>
    filter(str_detect(university_action_on_issue, "Correct Racist History"))

  return(lst(
    name_protests,
    correct_racist_history
  ))
}
