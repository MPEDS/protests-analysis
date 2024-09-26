get_ipeds_instructional_gender <- function(){
  years <- 2012:2018
  instructional_gender_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "SAL", year, "_IS.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = FALSE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)

      instructional_gender <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        select(UNITID, ARANK, SATOTLT, SATOTLW) |>
        # 7 = all instructional staff total
        filter(ARANK == 7) |>
        mutate(pct_women_instructors = 100*(SATOTLW/SATOTLT),
               year = year,
               uni_id = as.character(UNITID)) |>
        select(uni_id, year, pct_women_instructors)
    })

  return(instructional_gender_aggregated)
}
