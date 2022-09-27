# Have to pretend to be Harvard Dataverse site when requesting, hence the
# complicated URL
get_mit_elections_url <- function(){
  return("https://dvn-cloud.s3.amazonaws.com/10.7910/DVN/VOQCHQ/17f9e79c5c2-be7fac8a22ad.orig?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27countypres_2000-2020.csv&response-content-type=text%2Fcsv&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220927T145447Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAIEJ3NV7UYCSRJC7A%2F20220927%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=6ea585423d2f22071870ceb7b639733d88cdf941423891b300a9048e046d9b75")
}

get_mit_elections <- function(url){
  # cleanest dataset I've ever seen in my life
  elections <- read_csv(url) %>%
    filter(year %in% c(2012, 2016),
           party == "REPUBLICAN"
          ) %>%
    mutate(republican_vote_prop = candidatevotes / totalvotes) %>%
    select(year, fips = county_fips, republican_vote_prop)

  return(elections)
}
