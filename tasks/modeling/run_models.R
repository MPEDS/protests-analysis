run_models <- function(integrated, canonical_event_relationship, ipeds, us_covariates, uni_pub_xwalk_reference){
  timeseries <- create_timeseries(integrated |>
                                    filter(!str_detect(key, "Columbia|Reno")),
                                    canonical_event_relationship,
                                    ipeds,
                                    us_covariates,
                                    uni_pub_xwalk_reference)

  fit_cox_model <- function(subset, data) {
    formula <- as.formula(paste("Surv(protest_age, had_hazard_status) ~", paste(subset, collapse = " + ")))
    cox_model <- coxph(formula, data = data)

    return(cox_model)
  }

  uni_covariates <- c("is_uni_public", "tuition", "uni_nonwhite_prop",
                      "uni_total_pop", "pell")
  county_covariates <- c("white_prop", "mhi", "rent_burden", "republican_vote_prop")

  model_combinations <- map(list(uni_covariates, county_covariates), \(covs){
    # generate list of all possible covariate combinations
    covs_list <- map(covs, \(x){c(T, F)}) |>
      set_names(covs)
    do.call(expand_grid, covs_list) |>
      mutate(id = 1:n()) |>
      pivot_longer(cols = c(everything(), -id),
                   values_to = "is_variable_included") |>
      filter(is_variable_included) |>
      group_split(id) |>
      imap(\(cov_grp, i){
        grp_model <- fit_cox_model(cov_grp$name, timeseries)
        get_printable_model(grp_model, paste0("estimate_", i))
      }) |>
      reduce(full_join, by = "term") |>
      set_names("")
    }) |>
    set_names("uni_model_combinations", "county_model_combinations")

  uni_model <- coxph(Surv(protest_age, had_hazard_status) ~ is_uni_public
                     + tuition
                     + uni_nonwhite_prop + uni_total_pop + pell,
                    data = timeseries) |>
    get_printable_model()
  county_model <- coxph(Surv(protest_age, had_hazard_status) ~ white_prop +
                          mhi +
                          rent_burden +
                          republican_vote_prop,
                        data = timeseries) |>
    get_printable_model()

  list(
    lst(uni_model, county_model),
    model_combinations
  ) |>
    flatten()
}

get_printable_model <- function(model, name = "estimate"){
  meta <- tribble(
    ~term, ~estimate,
    "n", model$n,
    "log-likelihood test", summary(model)$logtest[3],
    "concordance", concordance(model)$concordance
  )

  tidy(model) |>
    bind_rows(meta) |>
    select(-statistic) |>
    mutate(stars = case_when(
      p.value <= 0.005 ~ "***",
      p.value <= 0.05 ~ "**",
      p.value <= 0.10 ~ "*",
      TRUE ~ ""
    ),
    estimate = ifelse(is.na(p.value), estimate, exp(estimate)),
    estimate = ifelse(is.na(p.value),
                      format_num(estimate),
                      paste0(format_num(estimate), stars, "\n(", format_num(std.error), ")")
                      )) |>
    select(term, "{name}" := estimate)
}

get_summary_statistics <- function(timeseries){
  universities <- timeseries |>
    group_by(uni_id) |>
    mutate(had_protest = any(as.logical(had_hazard_status), na.rm = TRUE)) |>
    # One row per university, independent of date
    select(-year, -had_hazard_status, -protest_age, -hazard_date) |>
    distinct() |>
    # Other variables that cannot be represented by the below numerical summary stats
    select(-uni_name, -ipeds_fips, -size_category, -carnegie, -tribal) |>
    pivot_longer(cols = c(everything(), -uni_id, -had_protest))

  map_dfr(c(TRUE, FALSE), \(protest_subset){
    universities |>
      filter(had_protest == protest_subset) |>
      group_by(name) |>
      summarize(mean = mean(value, na.rm = TRUE),
                min = min(value, na.rm = TRUE),
                max = max(value, na.rm = TRUE),
                first_quartile = quantile(value, 1/4, na.rm = TRUE),
                median = median(value, na.rm = TRUE),
                third_quartile = quantile(value, 3/4, na.rm = TRUE),
                missings = sum(is.na(value)),
                missing_pct = 100 * missings/length(value)
                ) |>
      mutate(across(where(is.numeric), format_num),
        had_protest = protest_subset)
  })

}

format_num <- function(num){
  case_when(
    abs(num) > 1e5 | abs(num) < 1e-4 ~ formatC(num, digits = 3, big.mark = ","),
    TRUE ~ prettyNum(round(num, digits = 3), big.mark = ",")
  )
}

