
get_non_USA_Canada <- function() {

  tar_load(integrated)

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
