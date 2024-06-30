# pulling all virtual events so that coders can pull their locations

get_virtual_events <- function() {

  con <- connect_sheriff()
  # using this instead of integrated for now
  canonical_events <- tbl(con, "canonical_event") |>
    filter(!str_detect(location, "USA"),
           !str_detect(location, "Canada"),
           !str_detect(key, "Umbrella")) |> collect()

  all_non_USA_canada_locations <- integrated |>
    filter(!grepl("USA", location),
           !grepl("Canada",location),
           !str_detect(key, "Umbrella"))

  mislabeled_locations <- all_non_USA_canada_locations |>
    filter(!is.na(location))

  virtual_events <- all_non_USA_canada_locations |>
    filter(is.na(location))

  writexl::write_xlsx(lst(all_non_USA_canada_locations, mislabeled_locations, virtual_events),
                      "docs/data_cleaning_requests/non_USA_canada_locations.xlsx")
}
