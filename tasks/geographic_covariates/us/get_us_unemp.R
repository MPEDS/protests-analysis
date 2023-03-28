get_us_unemp <- function(){
  years <- 2012:2018
  unemp <- map_dfr(years, function(year){
    url <- paste0("https://www.bls.gov/lau/laucnty", str_sub(year, 3, 4),
                 ".xlsx")
    path <- paste0(tempdir(), '/temp.xls')
    download.file(url, path, quiet = TRUE)
    dataset <- readxl::read_xlsx(path, skip = 5,
                                 col_names = c("x", "fips1", "fips2", "name",
                                 "year", "na", "na2", "na3", "na4",
                                 "unemp")) |>
      unite("geoid", fips1, fips2, sep = "") |>
      select(geoid, year, unemp) |>
      mutate(year = as.numeric(year)) |> filter(geoid != "NANA")
    return(dataset)
  })

  return(unemp)
}
