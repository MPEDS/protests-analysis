run_timeseries <- function(integrated, canonical_event_relationship, ipeds, us_covariates, uni_pub_xwalk_reference, us_geo){
  timeseries <- create_timeseries(integrated |>
                                    filter(!str_detect(key, "Columbia|Reno")),
                                  canonical_event_relationship,
                                  ipeds,
                                  us_covariates,
                                  uni_pub_xwalk_reference,
                                  us_geo)

  fit_cox_model <- function(subset, data) {
    formula <- as.formula(paste("Surv(protest_age, had_hazard_status) ~", paste(subset, collapse = " + ")))
    cox_model <- coxph(formula, data = data)

    return(cox_model)
  }

  covariates <- get_covariates()
  model_combinations <- covariates |>
    group_split(category) |>
    map(\(cov_dta){
      covs <- cov_dta$name
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
  full_model <- fit_cox_model(covariates$name, timeseries) |>
    get_printable_model()

  list(
    lst(uni_model, county_model, full_model),
    model_combinations
  ) |>
    flatten()
}

get_printable_model <- function(model, name = "estimate"){
  meta <- tribble(
    ~term, ~estimate,
    "n", model$n,
    "n_events", model$nevent,
    "log-likelihood test", summary(model)$logtest[3],
  )

  tidy(model) |>
    bind_rows(meta) |>
    select(-statistic) |>
    mutate(
      stars = case_when(
        p.value <= 0.005 ~ "***",
        p.value <= 0.05 ~ "**",
        p.value <= 0.10 ~ "*",
        TRUE ~ ""
      ),
      term = str_remove(term, "TRUE"),
      estimate = ifelse(is.na(p.value), estimate, exp(estimate)),
      estimate = ifelse(is.na(p.value),
                        format_num(estimate),
                        paste0(format_num(estimate), stars, "\n(", format_num(std.error), ")")
                        )) |>
    select(term, "{name}" := estimate) |>
    left_join(covariates, by = c("term" = "name")) |>
    mutate(term = ifelse(is.na(formatted), term, formatted)) |>
    select(term, -category, everything(), -formatted)
}

get_summary_statistics <- function(timeseries){
  covariates <- get_covariates()
  universities <- timeseries |>
    select(-year, -protest_age, -start_date) |>
    select(all_of(covariates$name), uni_id, had_hazard_status) |>
    pivot_longer(cols = c(everything(), -uni_id, -had_hazard_status))

  universities |>
    group_split(had_hazard_status) |>
    map_dfr(\(group_dta){
      stats <- group_dta |>
        group_by(had_hazard_status, name) |>
        summarize(mean = mean(value, na.rm = TRUE),
                  sd = sd(value, na.rm = TRUE),
                  min = min(value, na.rm = TRUE),
                  max = max(value, na.rm = TRUE),
                  first_quartile = quantile(value, 1/4, na.rm = TRUE),
                  median = median(value, na.rm = TRUE),
                  third_quartile = quantile(value, 3/4, na.rm = TRUE),
                  missings = sum(is.na(value)),
                  missing_pct = 100 * missings/length(value),
                  .groups = "drop"
                  ) |>
        left_join(covariates, by = "name") |>
        mutate(across(where(is.numeric), format_num)) |>
        select(had_hazard_status, name, category, everything()) |>
        arrange(had_hazard_status, category)
      correlations <- group_dta |>
        pivot_wider() |>
        select(all_of(stats$name)) |>
        cor(use = "pairwise.complete.obs") |>
        as_tibble(rownames = "term")
      stats |>
        left_join(correlations, by = c("name" = "term")) |>
        mutate(name = ifelse(is.na(formatted), name, formatted)) |>
        select(-formatted)
    })
}

replace_variable_names <- function(dta, colname = NULL, keep_category = FALSE){
  covariates <- get_covariates()
  new_dta <- dta |>
    left_join(covariates, by = "name" |> set_names(colname)) |>
    select(-{{colname}}) |>
    rename({{colname}} := formatted) |>
    select({{colname}}, category, everything())
  if(keep_category){
    return(new_dta)
  }
  return(new_dta |> select(-category))
}

#' To be plugged into rename_with()
rename_covariates <- function(str){
  covs <- get_covariates()
  return(covs$formatted[covs$name == str])
}
