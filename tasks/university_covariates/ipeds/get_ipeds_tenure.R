get_ipeds_tenure <- function(){
  years <- 2012:2018
  tenure_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "S", year, "_SIS.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = FALSE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)

      tenure <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        select(UNITID, FACSTAT, SISTOTL) |>
        # 10 = total, 40= non-tenure-track
        filter(FACSTAT %in% c(10, 40)) |>
        pivot_wider(names_from=FACSTAT, values_from = SISTOTL) |>
        mutate(prop_non_tenure = `40`/`10`,
               year = year,
               uni_id = as.character(UNITID)) |>
        select(uni_id, year, prop_non_tenure)

      return(tenure)
  })

  return(tenure_aggregated)
}
