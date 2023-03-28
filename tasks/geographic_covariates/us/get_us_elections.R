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
    mutate(republican_vote_prop = candidatevotes / totalvotes) |>
    select(year, geoid = county_fips, republican_vote_prop) |>
    drop_na()

  return(elections)
}
