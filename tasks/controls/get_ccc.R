get_ccc <- function(url){
  read_csv(url, guess_max = Inf) %>%
    select(ccc_protest_date = date, fips = fips_code)
}
