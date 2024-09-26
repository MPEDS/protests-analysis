get_ipeds_instructional_race <- function(){
  map_dfr(2012:2018, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "S", year, "_IS.zip")
      filename <- tempfile()
      download.file(url, filename, met = "curl", quiet = TRUE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)
      race <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(year = year)
      return(race)
  }) |>
    filter(SISCAT == 1, FACSTAT == 0) |>
    # nonwhite = (total - white) / total
    mutate(
      nonwhite_staff_pct = 100*(1-HRWHITT/HRTOTLT),
      uni_id = as.character(UNITID)) |>
    select(uni_id, nonwhite_staff_pct, year)
}

