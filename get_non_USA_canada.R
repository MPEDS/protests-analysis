
get_non_USA_Canada <- function() {

  tar_load(integrated)

  all_non_USA_canada_locations <- integrated |>
    filter(!grepl("USA", location)) |>
    filter(!grepl("Canada",location))

  mislabeled_locations <- all_non_USA_canada_locations |>
    filter(!is.na(location))

  NA_locations <- all_non_USA_canada_locations |>
    filter(is.na(location))

  writexl::write_xlsx(lst(all_non_USA_canada_locations, mislabeled_locations, NA_locations),
                      "docs/data-cleaning-requests/non_USA_canada_locations.xlsx")
}
