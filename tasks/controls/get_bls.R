get_bls <- function(){
  urls <- paste0("https://www.bls.gov/lau/laucnty",
                 c(90:99, paste0(0, 0:9), 10:18),
                 ".xlsx")

  unemp <- map_dfr(urls, function(url){
    data <- import(url, skip = 5,
                   col_names = c("x", "fips1", "fips2", "name",
                                 "year", "na", "na2", "na3", "na4",
                                 "unemp")) %>%
      unite("fips", fips1, fips2, sep = "") %>%
      select(fips, year, unemp)
    return(data)
  }) %>%
  mutate(year = as.numeric(year)) %>% filter(fips != "NANA")

  return(unemp)
}
