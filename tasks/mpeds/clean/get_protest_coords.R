#' Geocodes protest locations into a lookup table
#'
#' Uses GMaps API to turn semantic strings into lon/lat coords in WGS84.
#' Requires GMAPS_API_KEY in your .Renviron file. Heavily relies on
#' `httr` functions and `purrr` syntax.
#'
#' The wrapper function (at the top) relies on two helper objects: `get_coords`,
#' which actually queries Google Maps, and `suspect_locations`, which
#' defines a hand-coded set of locations for which universities should be used instead.
#' They aren't referenced in `_targets.R`, but because of how the hash
#' algorithm works, `targets` will still detect their changes.
#'
#' @param coder_table_wide The *wide* version of the coder table,
#' outputted by the get_coder_table_wide function.
#' @return A three-column tibble:
#' lon<numeric> | lat<numeric> | location<character>
get_protest_coords <- function(coder_table){
  locations <- coder_table %>%
    pull(location) %>%
    unlist() %>%
    unique()

  # build up initial list, not specific to any university
  message("Building up list of geocoded cities...")
  coords <- imap_dfr(locations, \(loc, index){
    message(index, "/", length(locations), ": ", loc)
    get_coords(loc)
  }) %>%
    filter(!is.na(lng), !is.na(lat))

  message("Building up list of geocoded universities...")
  coords <- imap_dfr(locations, \(loc, index){
    message(index, "/", length(locations), ": ", loc)
    get_coords(loc)
  }) %>%
    filter(!is.na(lng), !is.na(lat))

  # build up second pass
  message("Iterating over `coder_table` to integrate and double-check...")
  unique_unis <- unique(coder_table$university)
  uni_coords <- imap_dfr(unique_unis, \(uni, index){
    message(index, "/", length(unique_unis), ": ", uni)
    get_coords(uni)
  })

  return(bind_rows("city" = coords, "uni" = uni_coords, .id = "location_type"))
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


suspect_locations <- c(
  "virtual", "vitual",
  "St. Catherines, ON, USA",
  "_Other Form", "2014-04-08",
  "2014-04-15", "2015-10-29",
  "2016-03-20", "2017-09-24 Berkeley, CA, USA"
)
