get_ipeds_race <- function(){
  map_dfr(2012:2018, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "EFFY", year, ".zip")
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
    # Undergrads
    filter(EFFYLEV == 2) |>
    # nonwhite = (total - white) / total
    mutate(uni_total_pop = EFYTOTLT,
           uni_nonwhite_prop = (uni_total_pop - EFYWHITT)/uni_total_pop,
           uni_id = as.character(UNITID)) |>
    select(uni_id, uni_nonwhite_prop, uni_total_pop, year)
}
