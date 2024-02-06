#' Geocodes protest locations into a lookup table
#'
#' The wrapper function (at the top) relies on `get_coords`,
#' which actually queries Google Maps.
#'
#' @param events The *wide* version of the canonical events table,
#' outputted by the process_canonical_events function.
#' @return A four-column tibble:
#' lon<numeric> | lat<numeric> | location<character>
#'   | location_type<"city" | "uni" >
get_protest_coords <- function(events_wide){
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

  cities <- events_wide |>
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

  unique_unis <- events_wide |>
    pull(university) |>
    bind_rows() |>
    drop_na(university_name) |>
    pull(university_name) |>
    unique()

  uni_coords <- imap_dfr(unique_unis, \(uni, index){
    coords <- tryCatch(
      get_coords(uni, geocoded_cache),
      error = function(e){ stop(paste0("At ", uni, ": ", e))}
    )
    return(coords)
  }, .progress = "Fetching university coordinates") |>
    filter(!is.na(lng), !is.na(lat)) |>
    distinct()
  updated_cache <- bind_rows(city_coords, uni_coords)
  write_csv(updated_cache, geocoded_cache_filename)

  cleaned_events <- events_wide |>
    mutate(location = map_chr(location, ~ifelse(is.null(.), NA_character_, .[1]))) |>
    left_join(city_coords, by = "location") |>
    rename(location_lng = lng,
           location_lat = lat) |>
    nest_left_join(university, uni_coords,
                   by = c("university_name" = "location"))
  return(cleaned_events)
}

get_coords <- function(location, cache){
  if(location %in% cache$location){
    return(cache[location == cache$location, ])
  }

  response <- "https://maps.googleapis.com/maps/api/geocode/json" |>
    GET(query = list(
        address = location,
        key = Sys.getenv("GCP_API_KEY")
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
