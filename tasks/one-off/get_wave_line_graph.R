
<<<<<<< HEAD
<<<<<<< HEAD
get_wave_line_graph_wrapper <- function() {

  # load basic stuff in
  mpeds_raw <- tar_load(canonical_events)
  mpeds_sf <- tar_load(integrated)
=======
=======
>>>>>>> c1738bb (regenerating)
make_wave_line_graph <- function() {

  # load basic stuff in
  mpeds_raw <- tar_read(canonical_events)
  mpeds_sf <- tar_read(integrated)
<<<<<<< HEAD
>>>>>>> c1738bb (regenerating)
=======
>>>>>>> c1738bb (regenerating)
  mpeds <- mpeds_sf |>
    st_drop_geometry() |>
    mutate(country = if_else(str_extract(geoid, "us|canada") == "us", "US", "Canada") |>
             fct_relevel("US", "Canada")
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> c1738bb (regenerating)
    )
  relationships <- tar_read(canonical_event_relationship)

  # adding country row to integrated
  uni_country <- bind_rows(
    "US" = tar_read(ipeds),
    "Canada" = tar_read(glued),
    .id = "country"
  ) |>
    select(country, uni_id) |>
    distinct()

  mpeds <- mpeds |>
    nest_left_join(university, uni_country, by = "uni_id") |>
    mutate(country = map_chr(university, \(uni_dta){
      if(nrow(uni_dta) == 0){
        return(NA_character_)
      }
      if(nrow(drop_na(uni_dta, uni_id)) == 0){
        return(NA_character_)
      }

      # For each event, look through the university dataframe and pick a university
      # prioritizing "other univ where protest occurs" and then "publication" if it's available
      row <- uni_dta |>
        filter(!is.na(uni_id)) |>
        mutate(uni_name_source = factor(uni_name_source, levels = c(
          "other univ where protest occurs", "publication"
        ))) |>
        arrange(uni_name_source) |>
        slice_head(n = 1)

      # Then return the corresponding country
      row$country
    }),
    country_geo = if_else(str_extract(geoid, "us|canada") == "us", "US", "Canada"),
    country = if_else(is.na(country), country_geo, country))



  us_protests <- mpeds |>
    filter(country == "US")

  us_protests_issues <- us_protests |>
    select(canonical_id, key, start_date, issue, racial_issue) |>
    unnest(issue) |>
    unnest(racial_issue)

  blm_wave <- us_protests_issues |>
    select(-issue) |>
    filter(racial_issue == "Police violence") |>
    filter(start_date >= as.Date("2014-11-20") &
             start_date <= as.Date("2014-12-15"))

  make_weekly_count <- function(issue_df) {
    first_protest_date <- min(issue_df$start_date) #get first protest in the wave
    last_protest_date <- max(issue_df$start_date) #get last protest in the wave

    #create a week by week sequence of the wave, ranging from first to last protest
    all_weeks <- seq(floor_date(first_protest_date, "week"),
                     floor_date(last_protest_date, "week"),
                     by = "week")

    weekly_count <- issue_df |>
      mutate(week_start = floor_date(start_date, "week")) |>
      group_by(week_start) |>
      summarize(n = n()) |>
      complete(week_start = all_weeks, fill = list(n=0)) |>
      arrange(week_start)

    return(weekly_count)
  }

  make_daily_count <- function(issue_df) {
    first_protest_date <- min(issue_df$start_date) #get first protest in the wave
    last_protest_date <- max(issue_df$start_date) #get last protest in the wave

    all_days <- seq(first_protest_date, last_protest_date, by = "day")

    daily_count <- issue_df |>
      group_by(start_date) |>
      summarize(n = n()) |>
      complete(start_date = all_days, fill = list(n=0)) |>
      arrange(start_date)

    return(daily_count)
  }

  first_us_wave_summary <- tibble(
    wave = "First US Wave (BLM 2014)",
    criteria = "dates = late November/early December and racial_issue = \"Police violence\"",
    n_protests = nrow(blm_wave)
  )

  first_us_wave_weekly_count <- make_weekly_count(blm_wave)
  first_us_wave_daily_count <- make_daily_count(blm_wave)

  ggplot(data = first_us_wave_daily_count, aes(x = start_date, y = n)) +
    geom_line() +
    scale_x_date(date_breaks = "1 day",
                 date_labels = "%b %d") +
    expand_limits(y = 0) +
    labs(x = "Date", y = "Protest Count", title = "First US Wave (BLM)") +
    scale_y_continuous(expand = c(0, 0), breaks = c(0,5,10,15,20,25,30,35)) +
    theme(
      axis.text.x = element_text(angle = 40, vjust = 0, hjust=0, size = 8)
>>>>>>> c1738bb (regenerating)
    )
  relationships <- tar_read(canonical_event_relationship)

  # adding country row to integrated
  uni_country <- bind_rows(
    "US" = tar_read(ipeds),
    "Canada" = tar_read(glued),
    .id = "country"
  ) |>
    select(country, uni_id) |>
    distinct()

  mpeds <- mpeds |>
    nest_left_join(university, uni_country, by = "uni_id") |>
    mutate(country = map_chr(university, \(uni_dta){
      if(nrow(uni_dta) == 0){
        return(NA_character_)
      }
      if(nrow(drop_na(uni_dta, uni_id)) == 0){
        return(NA_character_)
      }

      # For each event, look through the university dataframe and pick a university
      # prioritizing "other univ where protest occurs" and then "publication" if it's available
      row <- uni_dta |>
        filter(!is.na(uni_id)) |>
        mutate(uni_name_source = factor(uni_name_source, levels = c(
          "other univ where protest occurs", "publication"
        ))) |>
        arrange(uni_name_source) |>
        slice_head(n = 1)

      # Then return the corresponding country
      row$country
    }),
    country_geo = if_else(str_extract(geoid, "us|canada") == "us", "US", "Canada"),
    country = if_else(is.na(country), country_geo, country))



  us_protests <- mpeds |>
    filter(country == "US")

  us_protests_issues <- us_protests |>
    select(canonical_id, key, start_date, issue, racial_issue) |>
    unnest(issue) |>
    unnest(racial_issue)

  blm_wave <- us_protests_issues |>
    select(-issue) |>
    filter(racial_issue == "Police violence") |>
    filter(start_date >= as.Date("2014-11-20") &
             start_date <= as.Date("2014-12-15"))

  make_weekly_count <- function(issue_df) {
    first_protest_date <- min(issue_df$start_date) #get first protest in the wave
    last_protest_date <- max(issue_df$start_date) #get last protest in the wave

    #create a week by week sequence of the wave, ranging from first to last protest
    all_weeks <- seq(floor_date(first_protest_date, "week"),
                     floor_date(last_protest_date, "week"),
                     by = "week")

    weekly_count <- issue_df |>
      mutate(week_start = floor_date(start_date, "week")) |>
      group_by(week_start) |>
      summarize(n = n()) |>
      complete(week_start = all_weeks, fill = list(n=0)) |>
      arrange(week_start)

    return(weekly_count)
  }

  make_daily_count <- function(issue_df) {
    first_protest_date <- min(issue_df$start_date) #get first protest in the wave
    last_protest_date <- max(issue_df$start_date) #get last protest in the wave

    all_days <- seq(first_protest_date, last_protest_date, by = "day")

    daily_count <- issue_df |>
      group_by(start_date) |>
      summarize(n = n()) |>
      complete(start_date = all_days, fill = list(n=0)) |>
      arrange(start_date)

    return(daily_count)
  }

  first_us_wave_summary <- tibble(
    wave = "First US Wave (BLM 2014)",
    criteria = "dates = late November/early December and racial_issue = \"Police violence\"",
    n_protests = nrow(blm_wave)
  )

  first_us_wave_weekly_count <- make_weekly_count(blm_wave)
  first_us_wave_daily_count <- make_daily_count(blm_wave)

  make_wave_line_graph <- function(daily_count_df,graph_title) {

    ggplot(data = daily_count_df, aes(x = start_date, y = n)) +
      geom_line() +
      scale_x_date(date_breaks = "1 day",
                   date_labels = "%b %d") +
      expand_limits(y = 0) +
      labs(x = "Date", y = "Protest Count", title = graph_title) +
      scale_y_continuous(expand = c(0, 0), breaks = c(0,5,10,15,20,25,30,35)) +
      theme(
        axis.text.x = element_text(angle = 40, vjust = 0, hjust=0, size = 8)
      )
  }

}

