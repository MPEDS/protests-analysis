# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
get_ipeds_finance <- function(){
  years <- 2012:2018
  finance_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      # 2018 -> "1718", as in the 2017-18 academic year. For the filename naming format
      year_format <- paste0(
        str_sub(year - 1, 3,4),
        str_sub(year, 3,4)
      )
      url <- paste0(base_url, "F", year_format, "_F2.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = FALSE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)
      finance <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(year = year,
               uni_id = as.character(UNITID),
               endowment_assets = as.numeric(F2H01)) |>
        select(year, uni_id, endowment_assets)
      return(finance)
  })
  return(finance_aggregated)
}
