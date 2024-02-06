# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
get_directory_url <- function(year){
  base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
  full_url <- paste0(base_url, "HD", year, ".zip")
  return(full_url)
}

get_ipeds_directory <- function(){
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

clean_ipeds_directory <- function(directory){
  directory |>
    mutate(
      carnegie = case_when(
        CARNEGIE %in% c(15, 16) ~ "Doctoral",
        CARNEGIE %in% c(21, 22) ~ "Masters",
        CARNEGIE %in% c(31, 32, 33) ~ "Baccalaureate",
        CARNEGIE == 40 ~ "Associates",
        CARNEGIE == -2 ~ NA_character_,
        TRUE ~ "Other (specialized)"
      ),
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
      is_uni_public = case_when(
        CONTROL == 1 ~ TRUE,
        CONTROL %in% c(2, 3) ~ FALSE,
        TRUE ~ NA
      ),
     ipeds_fips = case_when(
       nchar(COUNTYCD) == 4 ~ paste0("0", COUNTYCD),
       nchar(COUNTYCD) == 5 ~ as.character(COUNTYCD),
       TRUE ~ NA_character_
     ),
    ) |>
    select(uni_id = UNITID, uni_name = INSTNM,
           ipeds_fips, size_category = INSTSIZE, is_uni_public,
           carnegie, hbcu, tribal, year) |>
    mutate(uni_id = as.character(uni_id))
}
