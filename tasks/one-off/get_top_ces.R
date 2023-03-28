get_top_ces <- function(){
  ces <- tar_read(canonical_events) |>
    filter(variable == "university-responses-text") |>
    select(key) |>
    distinct()

  articles <- get_articles()

  articles |>
    drop_na(canonical_key) |>
    right_join(ces, by = c("canonical_key" = "key")) |>
    group_by(canonical_key) |>
    count() |>
    arrange(desc(n)) |>
    ungroup() |>
    slice_head(n = 20) |>
    pull(canonical_key) |>
    paste0(collapse = "\n") |>
    cat()

}

