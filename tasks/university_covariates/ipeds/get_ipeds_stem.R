# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
get_ipeds_stem <- function(){
  years <- 2012:2018
  stem_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      url <- paste0(base_url, "C", year, "_A.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = FALSE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)
      # Ugh
      dhs_codes <- c(26, 27, 40, 14)
      stem <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(CIPCODE = str_sub(CIPCODE, 1, 2)) |>
        filter(CIPCODE %in% dhs_codes | CIPCODE == 99) |>
        group_by(UNITID, CIPCODE) |>
        summarize(count = sum(CTOTALT, na.rm=TRUE)) |>
        ungroup() |>
        pivot_wider(names_from = CIPCODE,
                    values_from = count,
                    values_fn = ~sum(., na.rm=T)) |>
        mutate(across(where(is.numeric), ~ifelse(is.na(.), 0, .)),
               prop_stem = (`14` + `26` + `27` + `40`)/`99`,
               year = year,
               uni_id = as.character(UNITID)) |>
        select(uni_id, year, prop_stem)


      return(stem)
  })

  return(stem_aggregated)
}

