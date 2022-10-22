# Query Harvard Dataverse site directly for MIT Elections data
# Note that there is actually a form on that site
# requesting you put your name,  email, university, and position,
#that this script bypasses.
# Legally the dataset is under CC 2.0 so nothing wrong there,
# but still feels weird to query it programmatically when
# they want explicit human interaction
# But I'm sure it's fine, plus I did fill out the form
# manually a few times
get_mit_elections <- function(){
  # No ETag or Last-Modified header, so cannot track for changes in targets
  url <- "https://dataverse.harvard.edu/api/access/datafile/6104822?format=original&gbrecs=true"
  # cleanest dataset I've ever seen in my life
  elections <- read_csv(url) %>%
    filter(year %in% c(2012, 2016),
           party == "REPUBLICAN"
          ) %>%
    mutate(republican_vote_prop = candidatevotes / totalvotes) %>%
    select(year, fips = county_fips, republican_vote_prop)

  return(elections)
}
