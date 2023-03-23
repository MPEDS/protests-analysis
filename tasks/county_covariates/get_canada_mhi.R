#' Median household income from StatCan
get_canada_mhi <- function(canada_cma_shapes){
  keys <- select(canada_cma_shapes, canada_geouid)
  url <- "https://www150.statcan.gc.ca/n1/en/tbl/csv/11100009-eng.zip?st=e8RYM2Cy"

  download_location <- tempfile()
  download.file(url, download_location)
  unzip(download_location, exdir = paste0(tempdir(), "/canada-mhi"))

  read_csv(paste0(tempdir(), "/canada-mhi/11100009.csv")) |>
    mutate(canada_geouid = str_sub(DGUID, 10, -1)) |>
    filter(`Family characteristics` == "Median total income, all families",
           REF_DATE %in% 2012:2018) |>
    # multiple = all because each geographic unit is repped multiple times,
    # once per year
    right_join(keys, by = "canada_geouid",
               multiple = "all") |>
    select(canada_geouid, canada_mhi = VALUE, year = REF_DATE)
}
