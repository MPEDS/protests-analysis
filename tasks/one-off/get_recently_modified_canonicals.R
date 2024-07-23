
# uses canonical event

# pulling canonical protest events created after 2023-11-22
# so coders can make sure university names are correct

get_recent_canonicals <- function(start_date) {

  source("tasks/mpeds/import/connect_sheriff.R")
  con <- connect_sheriff()
  canonical_events <- tbl(con, "canonical_event")

  integrated <- tar_read(integrated) |>
    st_drop_geometry() |>
    select(canonical_id,key, university) |>
    mutate(canonical_id = as.integer(canonical_id))

   canonical_events <- canonical_events |>
    select(id, last_updated) |>
    filter(last_updated >= as.Date(start_date)) |>
    collect()

  recent_canonicals <- canonical_events |>
    left_join(integrated, by = c("id" = "canonical_id")) |>
    unnest(cols = university)


}


#get_recent_canonicals("2023-11-22")
