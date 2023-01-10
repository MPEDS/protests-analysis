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
  # Filename not stored as separate target because we don't want
  # changes to the cache to trigger changes to the pipeline
  geocoded_cache_filename <-"tasks/mpeds/clean/geocoding_cache.csv"
  if(file.exists(geocoded_cache_filename)){
    geocoded_cache <- read_csv(geocoded_cache_filename, show_col_types = FALSE)
  } else {
    geocoded_cache <- tibble(
      lon = numeric(0), lat = numeric(0),
      location = character(0)
    )
  }

  cities <- events |>
    pull(location) |>
    unlist() |>
    {\(.) tibble(cities = .) }() |>
    drop_na(cities) |>
    distinct() |>
    pull(cities)

  city_coords <- imap_dfr(cities, \(loc, index){
    coords <- tryCatch(
      get_coords(loc, geocoded_cache),
      error = function(e){ stop(paste0("At ", loc, ": ", e))}
    )
    return(coords)
  }, .progress = "Fetching city coordinates") |>
    filter(!is.na(lng), !is.na(lat))

  unique_unis <- events |>
    pull(university) |>
    unlist() |>
    {\(.) tibble(unis = .) }() |>
    drop_na(unis) |>
    distinct() |>
    pull(unis)
  uni_coords <- imap_dfr(unique_unis, \(uni, index){
    coords <- tryCatch(
      get_coords(uni, geocoded_cache),
      error = function(e){ stop(paste0("At ", uni, ": ", e))}
    )
    return(coords)
  }, .progress = "Fetching university coordinates") |>
    filter(!is.na(lng), !is.na(lat))
  updated_cache <- bind_rows(city_coords, uni_coords)
  write_csv(updated_cache, geocoded_cache_filename)

  events <- events |>
    left_join(city_coords, by = "location") |>
    rename(location_lng = lng,
           location_lat = lat) |>
    # not sure how to do a join properly on a list-col, as the `university`
    # column is (e.g. multiple possible universities for a single event)
    # So far I have this very inefficient method
    mutate(university_locations = imap(
      university, \(uni_name, index){
        # if university name is null, return empty tibble
        if(is.null(uni_name)){
          return(tibble())
        }
        # otherwise, match it with the uni_coords geocoded set
        return(tibble(location = uni_name) |> left_join(uni_coords, by = "location"))
      }
    ))
  return(events)
}

get_coords <- function(location, cache){
  if(location %in% cache$location){
    return(cache[location == cache$location, ])
  }

  response <- "https://maps.googleapis.com/maps/api/geocode/json" |>
    GET(query = list(
        address = location,
        key = Sys.getenv("GMAPS_API_KEY")
      )) |>
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
