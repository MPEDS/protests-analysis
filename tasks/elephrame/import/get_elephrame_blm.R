# in this case, can't use tar_target(format = "url") to track online
# changes because the response doesn't provide ETag or Last-Modified
# headers
get_elephrame_blm <- function(){
  url <- "https://elephrame.com/textbook/mapdata/blm"
  filename <- tempfile()

  download.file(
    url = url,
    destfile = filename,
    headers = c(referer = "https://elephrame.com/textbook/BLM/chart")
  )

  county_shps <- counties() %>%
    mutate(fips = paste0(STATEFP, COUNTYFP)) %>%
    select(fips)

  # adding county matches to it via a spatial join
  blm <- read_sf(filename) %>%
    select(blm_protest_date = start, blm_protest_num = num) %>%
    mutate(blm_protest_date = as.Date(blm_protest_date)) %>%
    st_set_crs(st_crs(county_shps)) %>%
    st_join(county_shps, join = st_within) %>%
    st_drop_geometry()

  return(blm)
}
