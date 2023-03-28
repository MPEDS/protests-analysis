get_us_covariates <- function(){

  year_covariates <- list(
    get_us_nonwhite(),
    get_us_income(),
    get_us_unemp(),
    get_us_rentburden(),
    get_us_elections()
  )

}
