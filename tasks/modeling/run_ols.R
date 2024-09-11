# Not clearly defined -- November 2016 - February 2017 maybe?
# 393 protests with that, wow
get_trump_subset <- function(integrated){
  trump <- integrated |>
    st_drop_geometry() |>
    filter(
      map_lgl(issue, ~"Trump and/or his administration (Against)" %in% .),
      start_date > "2016-11-01",
      start_date < "2017-03-01"
      )
  return(trump)
}

# Should probably be something we have an RA tag individually
# This criteria gets 129 protests
get_brown_subset <- function(integrated){
  brown <- integrated |>
    st_drop_geometry() |>
    filter(
      map_lgl(issue, ~"Police violence/anti-law enforcement/criminal justice" %in% .) |
        map_lgl(racial_issue, ~"Police violence" %in% .),
      start_date > "2014-05-01",
      start_date < "2014-12-01"
    )
  return(brown)
}

# More clearly defined
# 109 rows
get_mizzou_subset <- function(integrated, canonical_event_relationship){
  mizzou_id <- 26
  mizzou_solidarity <- canonical_event_relationship |>
    filter(relationship_type == "solidarity", canonical_id2 == 26) |>
    pull(canonical_id1)
  mizzou <- integrated |>
    st_drop_geometry() |>
    filter(canonical_id %in% mizzou_solidarity)
  return(mizzou)
}

get_tbtn_subset <- function(integrated, canonical_event_relationship){
  campaign_ids <- canonical_event_relationship |> 
    filter(canonical_id2 == 6497) |> 
    pull(canonical_id1)
  
  integrated |> 
    filter(canonical_id %in% campaign_ids)
}

join_universities <- function(subset, ipeds, us_covariates, uni_pub_xwalk_reference){
  with_university <- subset |>
    # University covariates, which are present as a nested tibble, have to have
    # the relevant entry selected and brought out. Convoluted logic
    # that should have its own function, but essentially says "pick 'other univ where protest occurs'"
    # if available, publication if not. And drop all NAs for uni IDs
    nest_select(university, uni_id, uni_name_source) |>
    unnest(university) |>
    group_by(key) |>
    filter(!is.na(uni_id), (uni_name_source %in% c("other univ where protest occurs", "publication"))) |>
    mutate(uni_name_source = factor(uni_name_source, levels = c(
      "other univ where protest occurs", "publication"
      )),
      year = lubridate::year(start_date)) |>
    arrange(key, uni_name_source) |>
    slice_head(n = 1)

  mpeds_universe_ids <- uni_pub_xwalk_reference |>
    # filter(source == "UWIRE Affiliate") |>
    drop_na(uni_id) |>
    pull(uni_id) |>
    unique()
  mpeds_universe <- ipeds |>
    filter(uni_id %in% mpeds_universe_ids)

  with_covariates <- with_university |>
    select(start_date, year, uni_id, key) |>
    full_join(mpeds_universe, by = c("uni_id", "year")) |>
    mutate(
      # Assign (latest possible) date for universities without protests
      protest_age = if_else(
        is.na(start_date), max(subset$start_date, na.rm = TRUE), start_date
      )
    ) |>
    # We need to do a full join to also get info for schools that didn't have a
    # protest, but this gets additional years' data too --
    # IPEDS includes data from 2014, 2012, etc, so we need to constrain records to the
    # given time period by comparing with the dates joined that cover the
    # specific time period of interest
    filter(year == lubridate::year(protest_age)) |>
    mutate(ipeds_fips = paste0("us_", ipeds_fips)) |>
    left_join(us_covariates, by = c("ipeds_fips" = "geoid", "year")) |>
    mutate(
      tuition = tuition / 1000,
      uni_total_pop = uni_total_pop / 1000,
      ipeds_fips = paste0("us_", ipeds_fips),
      is_uni_public = as.numeric(is_uni_public),
      had_protest = !is.na(key)
    ) |>
    select(-protest_age) |>
    ungroup()
  return(with_covariates)
}

model_helper <- function(subset, variables){
  covariates <- get_covariates()
  formula <- as.formula(paste("had_protest ~", paste(variables, collapse = " + ")))
  model <- glm(formula, data = subset, family=binomial)
  null_mod <- glm("had_protest ~ 1", data = subset, family = binomial)
  model_sum <- summary(model)
  meta <- tribble(
    ~term, ~estimate,
    "n", nrow(model$model),
    "NAs", length(model$na.action),
    "Incidents", sum(model$model$had_protest),
    "McFadden's r-squared", as.numeric(1-logLik(model)/logLik(null_mod)),
    "Adj. McFadden's r-squared", as.numeric(1-(logLik(model) - attr(logLik(model), "df"))/logLik(null_mod)),
    "BIC", BIC(model)
  )

  broom::tidy(model) |>
    mutate(estimate = exp(estimate)) |> 
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
      estimate = ifelse(is.na(p.value),
                        format_num(estimate),
                        paste0(format_num(estimate), stars, "\n(", format_num(std.error), ")")
                        )) |>
    select(term, estimate) |>
    left_join(covariates, by = c("term" = "name")) |>
    mutate(term = ifelse(is.na(formatted), term, formatted)) |>
    select(term, everything(), -category, -formatted)
}

run_subset <- function(subset){
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
          message(cov_grp$name)
          model_helper(subset, cov_grp$name)
        }) |>
        reduce(full_join, by = "term") |>
        mutate(across(everything(), ~replace_na(., ""))) |>
        set_names("")

    }) |>
    set_names("uni_model_combinations", "county_model_combinations")

  full_model <- model_helper(subset, covariates$name)

  lst(model_combinations, lst(full_model)) |> flatten()
}



run_ols <- function(integrated,
                    canonical_event_relationship,
                    ipeds,
                    us_covariates,
                    uni_pub_xwalk_reference) {
  models <- lst(
    trump = get_trump_subset(integrated),
    brown = get_brown_subset(integrated),
    mizzou = get_mizzou_subset(integrated, canonical_event_relationship),
    take_back_the_night = get_tbtn_subset(integrated, canonical_event_relationship)
  ) |>
    imap(\(subset, name) {
      model_subset <- run_subset(join_universities(subset, ipeds, us_covariates, uni_pub_xwalk_reference))

      writexl::write_xlsx(model_subset,
                          paste0("docs/data-cleaning-requests/modeling/", name, ".xlsx"))

      return(model_subset$full_model)
    })
    
  models |> 
    imap(\(x, name){
      x |> 
        rename({{name}} := estimate)
    }) |> 
    reduce(left_join, by = "term")
}
