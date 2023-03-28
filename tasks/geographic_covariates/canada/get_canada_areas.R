#' Downloads provinces and territories from CensusMapper API using cancensus
#' Is not really the "right" way to go about this, since 1) not official shapes
#' and 2) have to query random data to get associated shapefiles,
#' but the official Census shapefiles are way too large to work with
get_canada_areas <- function(){
  canada_province_shapes <- cancensus::get_census(dataset = "CA21", regions = list(C = "Canada"),
                                  geo_format = "sf", level = "PR") |>
    select(canada_province_id = GeoUID, province_name = name)
  return(canada_province_shapes)
}
