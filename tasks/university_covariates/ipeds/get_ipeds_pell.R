get_ipeds_pell <- function(){
  map_dfr(2012:2018, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      year_string <- paste0(
        str_sub(year - 1, 3, 4),
        str_sub(year, 3, 4)
      )
      url <- paste0(base_url, "SFA", year_string, ".zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = TRUE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)
      pell <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(year = year)
      return(pell)
  }) |>
    # Percent of full-time first-time undergraduates awarded Pell grants
    mutate(pell = as.numeric(PGRNT_P),
           uni_id = as.character(UNITID)) |>
    select(uni_id, pell, year)
}
