# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
get_directory_url <- function(year){
  base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
  full_url <- paste0(base_url, "HD", year, ".zip")
  return(full_url)
}

get_school_directory <- function(){
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
  })
  return(directory_aggregated)
}

clean_school_directory <- function(directory){
  directory |>
    mutate(
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
    select(uni_id = UNITID, uni_name = INSTNM,
           size_category = INSTSIZE,
           hbcu, tribal, year) |>
    mutate(uni_id = as.character(uni_id))
}
