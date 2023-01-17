#' Gets Census subdivisions from Statistics Canada
#' Cannot use tar_target(..., format = "url") because the URL performs a redirect
#' when queried for its headers only, which targets asks for in order to determine
#' whether to fetch or not. A shame because this is one of our largest sources
#' in bytes and can take a while to download
get_canada_shapefiles <- function(){
  download_location <- tempfile()
  download.file(
    "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcsd000b21a_e.zip",
    download_location
  )

  unzip(download_location,
        exdir = paste0(tempdir(), "/canada-shapefiles"))

  canada_shapefiles <- read_sf(paste0(tempdir(), "/canada-shapefiles")) |>
    select(canada_census_subdivision = CSDNAME) |>
    st_transform(4326) |>
    st_make_valid()

  return(canada_shapefiles)
}
