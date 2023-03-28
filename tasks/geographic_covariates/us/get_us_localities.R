get_us_localities <- function(){
  xwalk <- fips_codes |>
    mutate(geoid= paste0("us_", state_code, county_code)) |>
    select(geoid, area_name = state_name)

  us_localities <- counties() |>
    mutate(geoid = paste0("us_", GEOID),
           locality_name = NAME) |>
    select(geoid, locality_name) |>
    left_join(xwalk, by = "geoid")

    select(geoid, locality_name = CMANAME,
           area_name, region_name) |>

  return(us_localities)
}
