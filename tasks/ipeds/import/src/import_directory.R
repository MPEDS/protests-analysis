# for now just a placeholder function (it does something, but nothing useful)
# to get things going
import_directory <- function(){
  years <- 2012:2018
  base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"

  map_dfr(years, function(year){
    full_url <- paste0(base_url, "HD", year, ".zip")

    filename <- tempfile()
    dir <- tempdir()
    download.file(full_url, filename, method = "curl")
    unzipped_filename <- unzip(filename, exdir = dir)

    read_csv(unzipped_filename)
  })
}
