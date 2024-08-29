get_training_events <- function(){
  source("tasks/mpeds/import/connect_sheriff.R")
  con <- connect_sheriff()
  relationship <- tbl(con, "canonical_event_relationship")
  events <- tbl(con, "canonical_event")
  user <- tbl(con, "user") |> select(id, username)

  training <- events |>
    left_join(user, by = c("coder_id" = "id")) |>
    filter(str_detect(username, "training")) |>
    collect()

  keys <- events |>
    select(id, key)
  affected_relationship <- relationship |>
    filter(canonical_id2 %in% training$id | canonical_id1 %in% training$id) |>
    left_join(keys, by = c("canonical_id2" = "id")) |>
    rename(umbrella_key = key) |>
    left_join(keys, by = c("canonical_id1" = "id"))

  affected_relationship |>
    select(relationship_type, umbrella_key, key) |>
    collect() |>
    write_csv("docs/data-cleaning-requests/training_event_connections.csv")
}
