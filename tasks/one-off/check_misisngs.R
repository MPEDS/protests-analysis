investigate_missing_covariates <- function(integrated, covariates){
  covariates <- get_covariates()

  integrated |>
    st_drop_geometry() |>
    filter(!str_detect(key, "Umbrella")) |>
    select(key, geoid, covariates$name[covariates$category == "County"]) |>
    filter(if_any(everything(), is.na))
    pivot_longer(cols=everything()) |>
    group_by(name) |>
    summarize(prop_na = sum(is.na(value))/n())

  us_covariates |>
    mutate(across(everything(), as.character)) |>
    pivot_longer(cols=c(everything(), -year)) |>
    group_by(year, name) |>
    summarize(prop_na = sum(is.na(value))/n())
}
