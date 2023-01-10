#' Integrates all targets into a single dataset. Should always be the
#' last target formed before analysis.
integrate_targets <- function(
    geocoded,
    uni_directory,
    ipeds_xwalk,
    county_covariates = list(),
    ccc,
    uni_covariates = list()
){
  # for now convert "university" to simple column and match on that
  with_ipeds <- geocoded |>
    mutate(
      university = map_chr(university, ~ifelse(is.null(.), NA_character_, .))
    ) |>
    left_join(rename(ipeds_xwalk, uni_id = id), by = c(university = "og_name")) |>
    select(-university) |>
    rename(university = true_name) |>
  # get a clean year for the start date -- only one currently that has two, have to debug
    mutate(start_date = map_chr(start_date, ~ifelse(is.null(.), NA_character_, .[1])),
           start_date = as.Date(start_date),
           year = lubridate::year(start_date)) |>
    left_join(uni_directory, by = c("uni_id" = "id", "year"))

  # ccc_joinable <- ccc |>
  #   arrange(fips, date) |>
  #   mutate(
  #     protest_last_five_days = lag(date, n = 5)
  #     )

  # can't figure out how to normally append a tibble as the first item of
  # the list lol so instead I'll do it this way
  with_covariates <- list(list(with_ipeds), county_covariates) |>
    flatten() |>
    reduce(left_join, by = c("fips", "year")) # |>
    # left_join(mutate(ccc, has_ccc_protest = TRUE),
    #           by = c("fips", "start_date" = "ccc_protest_date")
    #           ) |>
    # mutate(has_ccc_protest = ifelse(is.na(has_ccc_protest), FALSE, TRUE))

  return(with_covariates)

}
