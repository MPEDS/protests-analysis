get_multiyear_campaign <- function(){

  # Just FYI, we typically use July 1 - June 30 as the year, eg July 1, 2015-June 30, 2016.
  tar_load(integrated)
  tar_load(canonical_event_relationship)
  campaigns <- canonical_event_relationship |>
    filter(relationship_type == "campaign") |>
    select(canonical_id = canonical_id1,
           campaign_id = canonical_id2) |>
    collect()

  keys <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key) |>
    mutate(canonical_id = as.integer(canonical_id))

  canonical_campaigns <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key, start_date, end_date) |>
    mutate(canonical_id = as.numeric(canonical_id),
           end_date = as.Date(end_date)) |>
    left_join(campaigns, by = "canonical_id") |>
    drop_na(campaign_id)

  assign_school_year <- function(date){
    # "2016-06-15" -> 2015
    # "2016-07-15" -> 2016
    calendar_year <- year(date)
    july_1st <- as.Date(paste0(calendar_year, "-07-01"))
    # If July 1 or after, categorize academic year as current calendar year,
    # if not, categorize as previous
    if_else(date >= july_1st, calendar_year, calendar_year - 1)
  }

  multiyear_campaigns <- canonical_campaigns |>
    group_by(campaign_id) |>
    summarize(start = min(start_date, na.rm = TRUE),
              end = max(start_date, end_date, na.rm = TRUE),
              events = paste0(key, collapse = ", ")) |>
    filter(!is.infinite(start), !is.infinite(end),
           assign_school_year(start) != assign_school_year(end)) |>
    left_join(keys, by = c("campaign_id" = "canonical_id")) |>
    select(campaign_key = key, everything(), -campaign_id)

  # Find missing values
  canonical_campaigns |>
    group_by(campaign_id) |>
    filter(all(is.na(start_date)))
  # Umbrella_UniversityofWisconsin_AntiRacism_2018_April

  return(multiyear_campaigns)
}
