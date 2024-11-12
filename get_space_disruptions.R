
get_space_disruptions <- function() {

  integrated <- tar_read(integrated)

  # filtering for relevant protest forms
  space_disruptions <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key, form, location, description, start_date, end_date) |>
    filter(map_lgl(form, ~ any(. %in% c("Blockade/slowdown/disruption",
                                        "Occupation/sit-in",
                                        "March",
                                        "Boycott",
                                        "Rally/demonstration",
                                        "Property damage",
                                        "Riot")))) |>
    # double checking that rounded numbers are right
    mutate(duration_days = as.numeric(difftime(end_date, start_date, units = "days")),
           duration_rounded = round(duration_days),
           duration = ifelse(duration_days < 1,
                             "less than 1 day",
                             paste0(duration_rounded, " days"))) |>
    # removing unnecessary columns
    select(-duration_days, -duration_rounded)


  multiple_day_space_disruptions <- space_disruptions |>
    filter(duration != "less than 1 day")

  multiple_day_protests <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key, form, location, description, start_date, end_date) |>
    mutate(duration_days = as.numeric(difftime(end_date, start_date, units = "days")),
           duration_rounded = round(duration_days),
           duration = ifelse(duration_days < 1,
                             "less than 1 day",
                             paste0(duration_rounded, " days"))) |>
    # removing unnecessary columns
    select(-duration_days, -duration_rounded) |>
    filter(duration != "less than 1 day") |>
    # removing petitions
    filter(form != "Petition")

  encampments <- integrated |>
    # the fancy regex for this ("\bcamp(?:ed|ing|s|camp)\b(?!\s?us)") turns up the same results
    # so i'm just leaving the full words here for clarity
    filter(map_lgl(tolower(description), ~any(str_detect(., "camping|camped|encampment"))))



  writexl::write_xlsx(lst(space_disruptions, multiple_day_space_disruptions, multiple_day_protests, encampments),
                      "docs/data-cleaning-requests/space-disruptions/space_disruptions.xlsx")

}
