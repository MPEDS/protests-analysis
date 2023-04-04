#' Gets Census metropolitan areas for Canada from Statistics Canada
#' Cannot use tar_target(..., format = "url") because the URL performs a redirect
#' when queried for its headers only, which targets asks for in order to determine
#' whether to fetch or not. A shame because this is one of our largest sources
#' in bytes and can take a while to download
get_canada_geo <- function(){
  download_location <- tempfile()
  download.file(
    "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcma000b21a_e.zip",
    download_location
  )

  unzip(download_location,
        exdir = paste0(tempdir(), "/canada-shapefiles"))

  # Cannot find a programmatic way to do a CMA -> province crosswalk, but
  # the SGC code system says first two digits are province
  # See info here, esp. table B
  # https://www.statcan.gc.ca/en/subjects/standard/sgc/2021/introduction
  provinces <- tribble(
    ~code, ~area_name,
    "10", "Newfoundland and Labrador",
    "11", "Prince Edward Island",
    "12", "Nova Scotia",
    "13", "New Brunswick",
    "24", "Quebec",
    "35", "Ontario",
    "46", "Manitoba",
    "47", "Saskatchewawn",
    "48", "Alberta",
    "59", "British Col",
    "60", "Yukon",
    "61", "Northwest Territories",
    "62", "Nunavut"
  )

  regions <- tribble(
    ~code, ~region_name,
    "1", "Atlantic",
    "2", "Quebec",
    "3", "Ontario",
    "4", "Parairies",
    "5", "British Columbia",
    "6", "Territories"
  )

  canada_geo <- read_sf(paste0(tempdir(), "/canada-shapefiles")) |>
    mutate(province_code = str_sub(CMAPUID, 1, 2),
           region_code = str_sub(CMAPUID, 1, 1)) |>
    left_join(provinces, by = c("province_code" = "code")) |>
    left_join(regions, by = c("region_code" = "code")) |>
    # See https://www150.statcan.gc.ca/n1/pub/92f0138m/92f0138m2019001-eng.htm
    # for DGUID logic
    mutate(geoid = str_sub(DGUID, 10, -1)) |>
    select(geoid, locality_name = CMANAME,
           area_name, region_name) |>
    st_transform(4326) |>
    st_make_valid()

  return(canada_geo)
}
