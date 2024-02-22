# Crowd Counting Consortium stores their data in two separate buckets
# For this project we're only interested in the 2017-2020 bucket as that is
# the only one with overlap with our data
get_ccc <- function(){
  # exclude university-related protests, as that's covered by MPEDS and we
  # don't want dups
  school_phrases <- "school|college|university|universities|students|teachers|faculty"
  ccc <- read_csv(
    "https://github.com/nonviolent-action-lab/crowd-counting-consortium/raw/master/ccc_compiled_2017-2020.csv",
    guess_max = Inf)
  ccc |>
    # filter(
    #   !str_detect(tolower(location_detail), school_phrases),
    #   !str_detect(tolower(actors), school_phrases)
    # )
    select(ccc_protest_date = date, fips = fips_code)
}
