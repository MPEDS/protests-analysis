get_tuition_url <- function(year){
  base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
  full_url <- paste0(base_url, "IC", year, ".zip")
  return(full_url)
}

get_tuition <- function(dummy_url){
  years <- 2012:2018

  tuition_aggregated <- map_dfr(
    years, function(year){
      url <- get_tuition_url(year)
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = TRUE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      tuition <- read_csv(unzipped_filename) %>%
        mutate(year = year)

      return(tuition)
    }) %>%
    select(id = UNITID)
}
