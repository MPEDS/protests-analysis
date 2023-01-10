get_directory_url <- function(year){
  base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
  full_url <- paste0(base_url, "HD", year, ".zip")
  return(full_url)
}

#' @param dummy_url is a placeholder and ignored; it's there
#' so that `targets` can send an update signal as a dependency
get_school_directory <- function(dummy_url){
  years <- 2012:2018
  directory_aggregated <- map_dfr(
    years, function(year){
      url <- get_directory_url(year)
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = TRUE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      directory <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(year = year)
      return(directory)
  }) |>
    mutate(
      # state_fips = case_when(
      #   nchar(FIPS) == 1 ~ paste0("0", FIPS),
      #   nchar(FIPS) == 2 ~ as.character(FIPS),
      #   TRUE ~ NA_character_
      #   ),
      fips = case_when(
        nchar(COUNTYCD) == 4 ~ paste0("0", COUNTYCD),
        nchar(COUNTYCD) == 5 ~ as.character(COUNTYCD),
        TRUE ~ NA_character_
        ),
      # fips = paste0(state_fips, county_fips),
      hbcu = case_when(
        HBCU == 1 ~ TRUE,
        HBCU == 2 ~ FALSE,
        TRUE ~ NA
        ),
      tribal = case_when(
        TRIBAL == 1 ~ TRUE,
        TRIBAL == 2 ~ FALSE,
        TRUE ~ NA
        ),
    ) |>
    select(id = UNITID, name = INSTNM,
           fips, size_category = INSTSIZE,
           hbcu, tribal, year)

  return(directory_aggregated)
}
