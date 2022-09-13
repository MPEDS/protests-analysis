get_ccc <- function(url){
  ccc <- read_csv(url, guess_max = Inf) %>%
    select(-starts_with("source_"))
}
