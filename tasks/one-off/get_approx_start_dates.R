# A spreadsheet with all of the canonical events that have an approximate start date.
# The fields that we need in this sheet are key, description, start date, end date,
# issue, racial issue, form.
get_approx_start_dates <- function(){
  tar_read(integrated) |>
    st_drop_geometry() |>
    filter(date_est == "approximate") |>
    select(key, description, start_date, end_date, issue, racial_issue, form) |>
    mutate(
      across(where(is.list), ~map(., ~.[. != "_Not relevant"])),
      across(where(is.list), ~map_chr(., ~paste0(., collapse = ", ")))
    ) |>
    arrange(start_date)
}
