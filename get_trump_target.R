
# Pull up all canonical events with Trump as Target and start and end date.
# Cleaning: Check that Trump is Target- Individual in events before 1/17/2017 and Domestic Govt afterwards

get_trump_target <- function(){

  tar_load(integrated)

  trump <- integrated |>
    st_drop_geometry() |>
    filter(map_lgl(issue, ~any(str_detect(., "Trump")))) |>
    filter(start_date >= as.Date("2016-11-01") &
             start_date <= as.Date("2017-2-28")) |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  writexl::write_xlsx(trump,
                      "docs/data-cleaning-requests/low-level-data-cleaning/trump_protests_targets.xlsx")
  return(trump)
}
