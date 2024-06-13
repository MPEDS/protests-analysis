get_unadjudicated_events <- function(){
  source("tasks/mpeds/import/connect_sheriff.R")
  con <- connect_sheriff()

  candidates <- tbl(con, "coder_event_creator")
  canonicals <- tbl(con, "canonical_event")
  link <- tbl(con, "canonical_event_link")

  valid_events <- tbl(con, "event_metadata") |>
    pull(event_id)

  adjudicated_candidate_ids <- candidates |>
    right_join(link, by = c("id" = "cec_id")) |>
    pull(event_id) |>
    unique()

  unlinked_events <- candidates |>
    collect() |>
    filter(!(event_id %in% adjudicated_candidate_ids))

  flags <- tbl(con, "event_flag") |>
    collect()

  completed_ids <- flags |>
    filter(flag == "completed") |>
    pull(event_id)

  flags_wide <- flags |>
    select(event_id, flag) |>
    distinct() |>
    mutate(dummy = T) |>
    pivot_wider(names_from = flag, values_from = dummy)
#
  not_completed_events <- candidates |>
    filter(!(event_id %in% completed_ids)) |>
    collect()
  users <- tbl(con, "user") |>
    select(id, username) |>
    collect()

  unadjudicated <- not_completed_events |>
    mutate(value = ifelse(value == "", text, value)) |>
    left_join(users, by = c("coder_id" = "id")) |>
    select(event_id, article_id, username, variable, value) |>
    pivot_wider(names_from = "variable", values_fn = list) |>
    janitor::clean_names() |>
    filter(event_id %in% valid_events) |>
    mutate(across(where(is.list), ~map_chr(., ~paste0(.[!is.na(.)], collapse = ",")))) |>
    filter(editorial != "yes", start_date != "") |>
    left_join(flags_wide, by = "event_id") |>
    select(event_id, article_id, username, article_desc, desc, start_date, end_date,
           location, issue, form, for_review = `for-review`)

  unadjudicated |>
    writexl::write_xlsx("docs/data-cleaning-requests/unadjudicated_events.xlsx")

  # Basic stats
  ur_codings <- unadjudicated |>
    filter(str_detect(username, "^UR_")) |>
    nrow()

  for_review <- unadjudicated |>
    filter(`for-review`)
}
