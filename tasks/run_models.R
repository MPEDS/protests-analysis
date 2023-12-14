run_models <- function(integrated, canonical_event_relationship, ipeds, covariates){
  # TODO: create structure that defines data manipulation conditions so we don't have to do
  # this so idiosyncratically/unstructured-ly
  mizzou_id <- integrated |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    pull(canonical_id)
  mizzou_events_ids <- canonical_event_relationship |>
    filter(canonical_id2 %in% mizzou_id) |>
    pull(canonical_id1)

  mizzou_events <- integrated |>
    filter(canonical_id %in% mizzou_events_ids)
  dates <- expand_grid(protest_age = seq.Date(min(mizzou_events$start_date, na.rm = TRUE),
                    max(mizzou_events$start_date, na.rm = TRUE),
                    by = 1), uni_id = unique(ipeds$uni_id))

  mizzou_events_cleaned <- mizzou_events |>
    st_drop_geometry() |>
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


  # Ensure each university only occupies one row
  # Gah so messy/hacky
  universities <- mizzou_events_cleaned |>
    ungroup() |>
    select(uni_id, start_date, year) |>
    group_by(uni_id) |>
    slice_min(order_by = start_date, n = 1, with_ties = FALSE) |>
    # Then ensure we have an indicator for protest hazard event, as
    # well as the entire IPEDS universe of universities
    full_join(ipeds, by = c("uni_id", "year")) |>
    select(-year) |>
    # Again, only keep one row per uni from IPEDS -- has to be done after the
    # join to know which rows to keep
    group_by(uni_id) |>
    mutate(start_date = ifelse(is.na(start_date), as.Date(Inf), start_date)) |>
    slice_min(order_by = start_date, n = 1, with_ties = FALSE) |>
    full_join(dates, by = "uni_id") |>
    filter(protest_age <= start_date) |>
    mutate(is_protest_day = ifelse(start_date == protest_age, 1, 0),
           start_date = ifelse(is.infinite(start_date), NA_Date_, start_date),
           # Protest age = number of days after first mizzou protest (oct 1 2015)
           protest_age = as.numeric(protest_age - min(mizzou_events$start_date, na.rm = TRUE)),
           tuition = tuition / 1000,
           uni_total_pop = uni_total_pop / 1000
           )

  # county_model <- coxph(Surv(protest_age, is_protest_day) ~ white_prop + unemp + mhi + rent_burden,
  #       data = mizzou_events_cleaned)

  uni_model <- coxph(Surv(protest_age, is_protest_day) ~ is_uni_public + tuition
                     + uni_nonwhite_prop + uni_total_pop + pell + hbcu + tribal,
                     data = universities)

}

get_printable_model <- function(model){
  summary(model)$coefficients |>
    as.data.frame() |>
    rownames_to_column() |>
    as_tibble()
}

get_summary_statistics <- function(universities){
  universities |>
    select(uni_id) |>
    distinct() |>
    left_join(ipeds) |>
    select(-uni_name) |>
    pivot_longer(cols = c(everything(), -uni_id)) |>
    group_by(name) |>
    summarize(mean = mean(value, na.rm = TRUE),
              min = min(value, na.rm = TRUE),
              max = max(value, na.rm = TRUE),
              first_quartile = quantile(value, 1/4, na.rm = TRUE),
              median = median(value, na.rm = TRUE),
              third_quartile = quantile(value, 3/4, na.rm = TRUE),
              missings = sum(is.na(value))
              )
}

list(
  all_universities = get_summary_statistics(universities),
  mizzou_protest_universities = get_summary_statistics(universities |> filter(is_protest_day == 1))
)



