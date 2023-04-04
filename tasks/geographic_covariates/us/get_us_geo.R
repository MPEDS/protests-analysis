get_us_geo <- function(us_regions){
  xwalk <- fips_codes |>
    mutate(geoid = paste0("us_", state_code, county_code)) |>
    select(geoid, area_name = state_name, state_code) |>
    left_join(us_regions, by = c("state_code" = "state")) |>
    # for now, since no canadian equivalent
    select(-division, -state_code) |>
    rename(region_name = region)

  us_geo <- counties() |>
    mutate(geoid = paste0("us_", GEOID),
           locality_name = NAME) |>
    select(geoid, locality_name) |>
    left_join(xwalk, by = "geoid")

  return(us_geo)
}
