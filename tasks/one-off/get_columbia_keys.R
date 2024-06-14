

get_columbia_keys <- function() {
  source("tasks/mpeds/import/connect_sheriff.R")

  con <- connect_sheriff()

  candidates <- tbl(con, "coder_event_creator")
  canonicals <- tbl(con, "canonical_event")
  link <- tbl(con, "canonical_event_link")

  relevant_canonicals <- canonicals |>
    filter(key=="20151102_Columbia_Occupation_UniversityGovernance" |
           key=="20151109_Columbia_Rally_CampusClimate") |>
    select(key, id) |>
    left_join(link, by = c("id" = "canonical_id")) |>
    select(key, cec_id, canonical_id = id) |>
    left_join(candidates, by = c("cec_id" = "id")) |>
    select(key, event_id) |>
    distinct() |>
    collect()


  writexl::write_xlsx(relevant_canonicals,"docs/data-cleaning-requests/columbia_candidates.xlsx")

}
