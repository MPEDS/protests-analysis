get_missing_events <- function(){
  test_ids <- c(9064, 9920, 9884)
  con <- connect_sheriff()

  cec <- tbl(con, "coder_event_creator") |> collect()
  mpeds <- tar_read(integrated) |> st_drop_geometry()

  map_dfr(test_ids, function(test_id){
    cec_ids <- cec |>
      filter(event_id == test_id) |>
      pull(id)

    canonical_ids <- cel |>
      filter(cec_id %in% cec_ids) |>
      pull(canonical_id) |>
      unique()

    canonical_keys <- mpeds |>
      filter(canonical_id %in% canonical_ids) |>
      pull(key) |>
      unique()

    tibble(
      test_id = test_id,
      canonical_keys = canonical_keys
    )
  })
}
