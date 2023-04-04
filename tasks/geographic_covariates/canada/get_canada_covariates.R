#' Aggregates the function colocated in this folder into a single dataset,
#' where each row is specific to both locality and year
get_canada_covariates <- function(localities){
  # Some Canadian CMAs are represented here twice because they reside across
  # multiple provinces or regions
  # This dedups them
  locality_keys <- select(localities, geoid) |>
    st_drop_geometry() |>
    distinct() |>
    mutate(geoid = str_remove_all(geoid, "^canada_"))

  year_covariates <- list(
    get_canada_unemp(locality_keys),
    get_canada_mhi(locality_keys)
  ) |>
    reduce(left_join, by = c("geoid", "year"))

  covariates <- list(
    list(year_covariates),
    get_canada_rentburden(locality_keys)
  ) |>
    list_flatten() |>
    reduce(left_join, by = "geoid") |>
    mutate(geoid = paste0("canada_", geoid))

  return(covariates)
}
