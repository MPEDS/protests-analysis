join_coords <- function(events, coords){

  cities <- coords %>%
    filter(location_type == "city") %>%
    select(-location_type)
  unis <- coords %>%
    filter(location_type == "uni") %>%
    select(-location_type) %>%
    rename(university = location)

  events <- events %>%
    left_join(cities, by = "location") %>%
    rename(location_lng = lng,
           location_lat = lat) %>%
    left_join(unis, by = "university") %>%
    rename(uni_lng = lng,
           uni_lat = lat)

  return(events)
}
