# Spot-checking work of certain adjudicators
get_adj_spot_check <- function(){
  con <- connect_sheriff()

  all_coders <- tbl(con, "user") |>
    select(id, username) |>
    collect()

  coders <- tribble(
    ~id, ~username, ~start_date, ~end_date,
    49, "adj_tianna", "2022-10-25", "2022-12-25",
    50, "adj_david", "2022-08-12", "2022-10-12",
    53, "adj_moneet", "2022-08-30", "2022-10-30",
  ) |>
    mutate(across(c(start_date, end_date), as.Date))

  # Two types of record updates: canonical event-level, link-level, candidate-event-level

  links <- tbl(con, "canonical_event_link") |>
    collect()
  cec <- tbl(con, "coder_event_creator") |>
    collect()

  updated_cec_records <- cec |>
    right_join(coders, by = c("coder_id" = "id")) |>
    filter(timestamp >= start_date, timestamp <= end_date) |>
    left_join(select(links, -coder_id), by = c("id" = "cec_id")) |>
    filter(!is.na(canonical_id), variable != "link") |>
    group_by(canonical_id) |>
    summarize(updated_candidate_event_records = paste(sort(unique(variable)), collapse = ", "))

  updated_links <- links |>
    right_join(coders, by = c("coder_id" = "id")) |>
    filter(timestamp >= start_date, timestamp <= end_date) |>
    left_join(cec, by = c("cec_id" = "id")) |>
    group_by(canonical_id, editor = username) |>
    summarize(updated_links = paste(sort(unique(variable)), collapse = ", "))

  created_canonical_events <- tbl(con, "canonical_event") |>
    collect() |>
    right_join(coders, by = c("coder_id" = "id")) |>
    filter(last_updated >= start_date, last_updated <= end_date) |>
    select(canonical_id = id, created_by = username)

  updated_canonical_events <- tbl(con, "canonical_event") |>
    collect() |>
    left_join(all_coders, by = c("coder_id" = "id")) |>
    select(canonical_id = id, key, description, last_updated,
           creator = username) |>
    left_join(select(links, canonical_id, cec_id), by = "canonical_id") |>
    left_join(select(cec, id, variable, value, text), by = c("cec_id" = "id")) |>
    mutate(value = ifelse(!is.na(text), text, value)) |>
    select(-text, -cec_id) |>
    pivot_wider(names_from = variable, values_from = value,
                values_fn = ~ifelse(length(.) > 1, paste0(., collapse = ", "), .)) |>
    janitor::clean_names() |>
    select(canonical_id, key, description, last_updated,
           start_date, creator,
           location, form, issue, racial_issue,
           issues_text, target, target_text) |>
    left_join(updated_links, by = "canonical_id") |>
    left_join(updated_cec_records, by = "canonical_id") |>
    filter(!is.na(updated_links) | !is.na(updated_candidate_event_records) |
            (canonical_id %in% created_canonical_events$canonical_id))  |>
    select(canonical_id, key, description, editor, creator,
           updated_links, updated_candidate_event_records,
           everything()
           ) |>
    group_by(editor)

  return(group_split(updated_canonical_events) |>
    set_names(group_keys(updated_canonical_events)$editor))
}
