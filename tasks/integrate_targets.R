#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
#' To recap, we've got three types of targets:
#' 1) School-level covariates
#' 2) county-level covariates, which all have the "fips" column
#' 3) other things
integrate_targets <- function(
    events,
    ipeds,
    ipeds_xwalk,
    county_covariates = list(),
    uni_covariates = list()
){
  # for now convert "university" to simple column and match on that
  with_ipeds <- events %>%
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) %>%
    left_join(rename(ipeds_xwalk, uni_id = id), by = c(university = "og_name")) %>%
    select(-university) %>%
    rename(university = true_name) %>%
  # get a clean year for the start date -- only one currently that has two, have to debug
    mutate(start_date = map_chr(start_date, ~ifelse(is.null(.), NA_character_, .[1])),
           year = lubridate::year(start_date)) %>%
    left_join(ipeds, by = c("university" = "name", "year"))

  # can't figure out how to normally append a tibble as the first item of
  # the list lol so instead I'll do it this way
  with_covariates <- list(list(with_ipeds), county_covariates) %>%
    flatten() %>%
    reduce(left_join, by = c("fips", "year"))

  return(with_covariates)

}
