#' Aggregates the function colocated in this folder into a single dataset,
#' where each row is specific to both locality and year
get_canada_covariates <- function(canada_rentburden, canada_mhi, localities){
  # Some Canadian CMAs are represented here twice because they reside across
  # multiple provinces or regions
  # This dedups them
  locality_keys <- select(localities, geoid) |>
    st_drop_geometry() |>
    distinct() |>
    mutate(geoid = str_remove_all(geoid, "^canada_"))

  year_covariates <- list(
    # get_canada_unemp(locality_keys),
    canada_mhi,
  ) |>
    reduce(left_join, by = c("geoid", "year"))

  covariates <- list(
    list(year_covariates),
    # canada_rentburden
  ) |>
    list_flatten() |>
    reduce(left_join, by = "geoid") |>
    mutate(geoid = paste0("canada_", geoid))

  return(covariates)
}

