#' helper function; useful for getting targets to track dependencies
get_mhi_urls <- function(){
  base_url <- "https://www2.census.gov/programs-surveys/saipe/datasets/"
  urls <- map_chr(2012:2018, function(year){
    paste0(base_url, year, "/", year, "-state-and-county/est",
           str_sub(year, -2, -1), "all.xls")
  })

  return(urls)
}

#' median household income: taken from the Small Area Income
#' and Poverty Estimates (SAIPE) Program.
#' See https://www.census.gov/programs-surveys/saipe/technical-documentation.html
#' for documentation.
get_us_income <- function(){
  urls <- get_mhi_urls()
  income <- map_dfr(urls, function(url){
    year <- as.numeric(str_extract(url, "([0-9]){4}"))
    #different years start on different rows in their spreadsheets
    rows_to_skip <- case_when(year < 2005 ~ 1,
                              year >= 2005 & year < 2013 ~ 2,
                              year >= 2013 ~ 3)

    path <- paste0(tempdir(), '/temp.xls')
    download.file(url, path, quiet = TRUE)
    data <- suppressMessages(
      readxl::read_xls(path, skip = rows_to_skip)
    ) |>
      # inconsistent formatting between years -- some have
      # "State FIPS Code" and others just "State FIPS"
      select(
        starts_with("State FIPS"),
        starts_with("County FIPS"),
        `Median Household Income`
        ) |>
      rename(
        sfips = starts_with('State FIPS'),
        cfips = starts_with('County FIPS')
      ) |>
      #FIPS codes being coded as numeric means leading zeros
      # are chopped off; this adds them back on
      mutate(sfips = ifelse(nchar(sfips) == 1, paste0("0", sfips), sfips),
             cfips = case_when(nchar(cfips) == 1 ~ paste0("00", cfips),
                               nchar(cfips) == 2 ~ paste0("0", cfips),
                               nchar(cfips) == 3 ~ as.character(cfips))) |>
      unite("geoid", sfips, cfips, sep = "") |>
      mutate(year = year,
             mhi = suppressWarnings(
               as.numeric(`Median Household Income`)/1000)
             ) |>
      select(geoid, year, mhi)

    return(data)
  }) |>
    filter(nchar(geoid) == 5)
  #some metadata collected as regular data in the loop;
  # this last line throws it out

  return(income)
}
