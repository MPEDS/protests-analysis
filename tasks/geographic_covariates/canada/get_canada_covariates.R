#' Aggregates the function colocated in this folder into a single dataset,
#' where each row is a
get_canada_covariates <- function(localities){

  year_covariates <- list(
    get_canada_unemp(localities),
    get_canada_mhi(localities)
  ) |>
    reduce(left_join, by = c("geoid", "year"))

  covariates <- list(
    list(year_covariates),
    get_canada_rentburden(localities)
  ) |>
    list_flatten() |>
    reduce(left_join, by = "geoid") |>
    mutate(geoid = paste0("canada_", geoid))

  return(covariates)
}
