#' Geocodes protest locations into a lookup table
#'
#' Uses GMaps API to turn semantic strings into lon/lat coords in WGS84.
#' Requires GMAPS_API_KEY in your .Renviron file. Heavily relies on
#' `httr` functions and `purrr` syntax.
#'
#' The wrapper function (at the top) relies on `get_coords`,
#' which actually queries Google Maps.
#'
#' @param events The *wide* version of the canonical events table,
#' outputted by the process_canonical_events function.
#' @return A four-column tibble:
#' lon<numeric> | lat<numeric> | location<character>
#'   | location_type<"city" | "uni" >
get_protest_coords <- function(events){
  locations <- events %>%
    filter(!is.na(location)) %>%
    pull(location) %>%
    unique()

  message("Geocoding cities...")
  city_coords <- imap_dfr(locations, \(loc, index){
    message(index, "/", length(locations), ": ", loc)
    return(get_coords(loc))
  }) %>%
    filter(!is.na(lng), !is.na(lat))

  message("Geocoding universities...")
  unique_unis <- events %>%
    pull(university) %>%
    unique()
  uni_coords <- imap_dfr(unique_unis, \(uni, index){
    message(index, "/", length(unique_unis), ": ", uni)
    return(get_coords(uni))
  })

  events <- events %>%
    left_join(city_coords, by = "location") %>%
    rename(location_lng = lng,
           location_lat = lat) %>%
    mutate(university_locations = map(
      university, \(uni_name){
        # if university name is null, return empty tibble
        if(is.null(uni_name)){
          return(tibble())
        }
        # otherwise, match it with the uni_coords geocoded set
        map_dfr(uni_name, \(uni_name){
          return(uni_coords %>% filter(location == uni_name))
        }) %>%
          return()
      }
    ))
  return(events)
}

get_coords <- function(location){
  response <- "https://maps.googleapis.com/maps/api/geocode/json" %>%
    GET(query = list(
        address = location,
        key = Sys.getenv("GMAPS_API_KEY")
      )) %>%
    content(as = "parsed")

  if(response$status == "ZERO_RESULTS"){
    return(tibble(
    lat = NaN,
    lng = NaN,
    location = location
    ))
  }

  # and otherwise extract the correct response
  coords <- response$results[[1]]$geometry$location
  return(tibble(
    lat = coords$lat,
    lng = coords$lng,
    location = location
  ))
}
