export_canonical_ids <- function(){
  con <- connect_sheriff()
  tbl(con, "canonical_event") |>
    select(id, key) |>
    collect()
}
