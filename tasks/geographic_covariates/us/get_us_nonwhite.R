#' Grabs white proportion of counties
#' Since the ACS isn't expected to update the 2012-2018
#' entries, I will leave this function as dependency-less; it
#' will only run once.
get_us_nonwhite <- function(){
  variables <- c(
    "white" = "B01001A_001",
    "total" = "B01001_001"
  )

  # +2 to center the 5-year estimates
  white_prop <- map_dfr(2012:2018 + 2, function(year){
    result <- get_acs("county",
                      variables = variables,
                      year = year,
                      output = "wide") |>
      mutate(year = year - 2)
    return(result)
  }) |>
    mutate(white_prop = 100*(whiteE / totalE)) |>
    select(geoid = GEOID, white_prop, year)
}

