get_ccc <- function(url){
  # exclude university-related protests, as that's covered by MPEDS and we
  # don't want dups
  school_phrases <- "school|college|university|universities|students|teachers|faculty"
  ccc <- read_csv(url, guess_max = Inf)
  ccc |>
    # filter(
    #   !str_detect(tolower(location_detail), school_phrases),
    #   !str_detect(tolower(actors), school_phrases)
    # )
    select(ccc_protest_date = date, fips = fips_code)
}
