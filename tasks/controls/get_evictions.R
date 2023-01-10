get_evictions <- function(evictions_url){
  evictions <- read_csv(evictions_url, show_col_types = FALSE) |>
    select(id, filing_rate, judgement_rate, year) |>
    rename(fips = id,
           eviction_filing_rate = filing_rate,
           eviction_judgement_rate = judgement_rate
    ) |>
    filter(year %in% 2012:2018)
  return(evictions)
}
