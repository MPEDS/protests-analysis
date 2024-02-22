#' For some reason a ridiculously large file with way too much detail than one
#' would think this kind of table would be released with
download_canada_rentburden <- function(){

  directory_name <- file.path(rappdirs::user_cache_dir("protests"), "canada_rentburden")
  dir.create(directory_name, showWarnings = FALSE)
  download_location <- file.path(directory_name, "canada_rentburden_raw")

  if(!file.exists(download_location)){
    url <- "https://www150.statcan.gc.ca/n1/en/tbl/csv/98100328-eng.zip"
    download.file(url, download_location)
  }
  unzip(download_location, exdir = directory_name)

  read_csv(file.path(directory_name, "98100328.csv"),
           show_col_types = FALSE,
           lazy = TRUE)
}

get_canada_rentburden <- function(canada_rentburden_raw, locality_keys){
  canada_rentburden_raw |>
    filter(`Age (15C)` == "Total - Age",
           `Gender (3)` == "Total - Gender",
           `Statistics (3)` == "Count",
           `Immigrant status and period of immigration (11)` == "Total - Immigrant status and period of immigration",
           `Visible minority (15)` == "Total - Visible minority",
           `Shelter-cost-to-income ratio (8)` == "50% to less than 100%"
           ) |>
    mutate(
      rent_burden = `Core housing need (3):In core need[2]` / `Core housing need (3):Total - Household examined for core housing need[1]`,
      geoid = str_sub(DGUID, 10, -1)
      ) |>
    right_join(locality_keys, by = "geoid") |>
    select(geoid, rent_burden)
}
