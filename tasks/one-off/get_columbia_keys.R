

get_columbia_keys <- function() {
  source("tasks/mpeds/import/connect_sheriff.R")

  con <- connect_sheriff()

  candidates <- tbl(con, "coder_event_creator")
  canonicals <- tbl(con, "canonical_event")
  link <- tbl(con, "canonical_event_link")

  relevant_canonicals <- canonicals |>
    filter(key=="20151102_Columbia_Occupation_UniversityGovernance" |
           key=="20151109_Columbia_Rally_CampusClimate")
}
