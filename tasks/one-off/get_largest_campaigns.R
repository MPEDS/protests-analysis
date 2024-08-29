get_largest_campaigns <- function(){
  tar_load(integrated)
  tar_load(canonical_event_relationship)

  keys <- integrated |>
    select(canonical_id, key)
  campaigns <- canonical_event_relationship |>
    mutate(across(where(is.integer), as.character)) |>
    filter(relationship_type == "campaign") |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(campaign_lead = key, campaign_event = canonical_id1) |>
    mutate(type = "campaign")

  solidarity <- canonical_event_relationship |>
    mutate(across(where(is.integer), as.character)) |>
    filter(relationship_type == "solidarity") |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(campaign_lead = key, solidarity_event = canonical_id1) |>
    mutate(type = "solidarity")

  # Prepping some statistics -- min start date, max end date, # universities
  campaign_summary <- campaigns |>
    bind_rows(solidarity) |>
    left_join(integrated, by = c("campaign_event" = "canonical_id")) |>
    mutate(university_ids = map(university, ~.$uni_id),
           end_date = as.Date(end_date)) |>
    group_by(campaign_lead) |>
    summarize(
      # Not how you're supposed to do this but whatever
      n_campaign_event = sum(type == "campaign"),
      n_solidarity = sum(type == "solidarity"),
      n_universities = length(unique(unlist(university_ids))),
      min_start = min(start_date, na.rm=T),
      max_end = max(end_date, na.rm=T),
      est_length = ifelse(!is.infinite(max(end_date,na.rm=T)) & !is.na(max(end_date, na.rm = T)),
                          max(end_date, na.rm=T) - min(start_date, na.rm=T),
                          NA)
    ) |>
    arrange(desc(n_campaign_event))

  # Then for top 15 campaigns, a list of all of them
  top_15_campaigns <- integrated |>
    st_drop_geometry() |>
    left_join(campaigns, by = c("canonical_id" = "campaign_event")) |>
    filter(campaign_lead %in% campaign_summary$campaign_lead[1:15], !is.na(campaign_lead)) |>
    select(campaign_lead, key, description, publication, start_date,
           location, issue, racial_issue,
           university_reactions_to_protest,
           university_discourse_on_protest,
           university_action_on_issue,
           university_discourse_on_issue,
           police_activities,
           police_presence_and_size,
           type_of_police,
           protester_resistance_to_police) |>
    mutate(
      across(where(is.list),
      ~map_chr(., \(x){paste0(x[!(x %in% c("_Not relevant", "NA/Unclear"))], collapse = ", ")}))
    ) |>
    group_split(campaign_lead) |>
    map(\(dta){
      campaign_lead <- unique(dta$campaign_lead)
      list(dta) |>
        set_names(campaign_lead)
    }) |>
    flatten()

  lst(
    lst(campaign_summary),
    top_15_campaigns,
  ) |>
    flatten() |>
    writexl::write_xlsx("docs/data-cleaning-requests/campaign_summaries.xlsx")
}
