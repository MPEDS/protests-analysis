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

  blm_shps <- st_read(filename) %>%
    select(start, end,
           loc, sub, desc, num, url) %>%
    mutate(date = start,ko)
  return(blm_shps)
}
