get_us_rentburden <- function(){

  rent_burden <- map_dfr(2012:2018 + 2, function(year) {
    get_acs("county", variables = c(
      rent_30 = "B25070_007",
      rent_35 = "B25070_008",
      rent_40 = "B25070_009",
      rent_50 = "B25070_010",
      rent_total = "B25070_001"),
      output = "wide", year = year) |>
      mutate(year = year,
             rent_burden = (rent_30E + rent_35E + rent_40E + rent_50E)/rent_totalE
             ) |>
      select(year, rent_burden, geoid = GEOID)
    })

  return(rent_burden)
}
