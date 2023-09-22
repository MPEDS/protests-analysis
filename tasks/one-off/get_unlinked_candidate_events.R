# Requires "tidyverse", "RMariaDB" libraries
# and connect_sheriff()  from tasks/mpeds/import to be loaded
get_unlinked_candidate_events <- function(){
  con <- connect_sheriff()

  canonical_event_link <- tbl(con, "canonical_event_link") |> collect()
  event_metadata <- tbl(con, "event_metadata") |>
    collect() |>
    filter(!str_detect(coder_id, "^UR_|^PA_"))
  coder_event_creator <- tbl(con, "coder_event_creator") |> collect()

  cec_linked_ids <- canonical_event_link |>
    select(-id) |>
    left_join(coder_event_creator, by = c("cec_id" = "id")) |>
    pull(event_id) |>
    unique()

  uncodable_ids <- coder_event_creator |>
    filter(
      variable %in% c("no-protest", "non-campus",
                      "non-us", "historical",
                      "vague-event","duplicate")
    ) |>
    pull(event_id) |>
    unique()

  no_start_dates <- coder_event_creator |>
    select(event_id, variable, value) |>
    pivot_wider(names_from = "variable", values_fn = list) |>
    # filter for where start date is either all NAs or empty strings
    filter(map_lgl(`start-date`, function(date_lst){
      return(all(is.na(date_lst)) || all(date_lst == ""))
    })) |>
    pull(event_id) |>
    unique()

  linked_articles <- coder_event_creator |>
    filter(variable == "link") |>
    pull(article_id) |>
    unique()

  unlinked_events <- event_metadata |>
    # uncodable_ids and no_start_dates notably don't change the result set
    filter(!(event_id %in% cec_linked_ids),
           !(event_id %in% uncodable_ids),
           !(event_id %in% no_start_dates),
           !is.na(start_date),
           !(article_id %in% linked_articles)) |>
    rename(event_coder = coder_id)

  event_flag <- tbl(con, "event_flag") |>
    select(-id, -timestamp) |>
    collect()

  unlinked_events <- unlinked_events |>
    left_join(event_flag, by = "event_id") |>
    left_join(tbl(con, "user") |> collect(),
              by = c("coder_id" = "id")) |>
    select(-password, -authlevel, -id) |>
    select(flag_coder = username, flag, event_id, everything())

  return(unlinked_events)
}
