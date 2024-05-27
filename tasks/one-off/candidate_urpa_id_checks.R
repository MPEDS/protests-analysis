
get_candidate_urpa_id_checks <- function(){
  con <- connect_sheriff()
  coder_event_creator <- tbl(con, "coder_event_creator") |>
    filter(variable=="desc", str_detect(value,8733)) |>
    collect()
}
