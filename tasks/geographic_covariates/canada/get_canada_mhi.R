#' Median household income from StatCan
get_canada_mhi <- function(locality_keys){
  url <- "https://www150.statcan.gc.ca/n1/en/tbl/csv/11100009-eng.zip?st=e8RYM2Cy"

  download_location <- tempfile()
  download.file(url, download_location)
  unzip(download_location, exdir = paste0(tempdir(), "/canada-mhi"))

  read_csv(paste0(tempdir(), "/canada-mhi/11100009.csv"),
           show_col_types = FALSE) |>
    mutate(geoid = str_sub(DGUID, 10, -1)) |>
    filter(`Family characteristics` == "Median total income, all families",
           REF_DATE %in% 2012:2018) |>
    # multiple = all because each geographic unit is repped multiple times,
    # once per year
    right_join(locality_keys, by = "geoid",
               multiple = "all") |>
    select(geoid, mhi = VALUE, year = REF_DATE)
}
