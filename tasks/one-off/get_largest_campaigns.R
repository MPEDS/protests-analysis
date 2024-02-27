get_largest_campaigns <- function(){
  tar_load(integrated)
  tar_load(canonical_event_relationship)

  keys <- integrated |>
    select(canonical_id, key)
  campaigns <- canonical_event_relationship |>
    mutate(across(where(is.integer), as.character)) |>
    filter(relationship_type == "campaign") |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(campaign_lead = key, campaign_event = canonical_id1)

  # one sheet with a list of Biggest campaigns
  campaign_summary <- campaigns |>
    group_by(campaign_lead) |>
    count(name = "number_events") |>
    arrange(desc(number_events))

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
    flatten()
}
