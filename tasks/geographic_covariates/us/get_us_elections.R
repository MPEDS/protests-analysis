# Query Harvard Dataverse site directly for MIT Elections data
# Note that there is actually a form on that site
# requesting you put your name,  email, university, and position,
#that this script bypasses.
# Legally the dataset is under CC 2.0 so nothing wrong there,
# but still feels weird to query it programmatically when
# they want explicit human interaction
# But I'm sure it's fine, plus I did fill out the form
# manually a few times
get_us_elections <- function(){
  # No ETag or Last-Modified header, so cannot track for changes in targets
  url <- "https://dataverse.harvard.edu/api/access/datafile/6104822?format=original&gbrecs=true"
  elections <- read_csv(url, show_col_types = FALSE) |>
    filter(year %in% c(2012, 2016),
           party == "REPUBLICAN"
          ) |>
    mutate(republican_vote_prop = 100*(candidatevotes / totalvotes)) |>
    select(year, geoid = county_fips, republican_vote_prop) |>
    drop_na()

  # Interpolate this for 2013-2015 and 2016-2017
  keys <- expand_grid(geoid = unique(elections$geoid),
                      true_year = min(elections$year):2018)
  elections <- elections |>
    full_join(keys, by = "geoid") |>
    # Produces empty values and many false matches --
    # a row that has year (true_year) as 2018 should be matched with 2016 election data
    filter(true_year >= year, true_year < year + 4) |>
    select(-year) |>
    rename(year = true_year)

  return(elections)
}
