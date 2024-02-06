get_ipeds_tuition <- function(){
  map_dfr(2012:2018, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "IC", year, "_AY.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = TRUE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      tuition <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(year = year)
      return(tuition)
  }) |>
    mutate(tuition = as.numeric(TUITION2),
           uni_id = as.character(UNITID)) |>
    select(uni_id, tuition, year)
}
