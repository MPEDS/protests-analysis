get_ccc <- function(url){
  read_csv(url, guess_max = Inf) %>%
    select(date, fips = fips_code)
}
