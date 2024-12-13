# Compare campaigns and umbrellas to find out discrepencies in how we defined them
get_campaign_umbrellas <- function(){
  source("tasks/mpeds/import/connect_sheriff.R")
  con <- connect_sheriff()
  campaigns <- tbl(con, "canonical_event_relationship") |>
    filter(relationship_type == "campaign") |>
    collect() |>
    pull(canonical_id2)

  pick_university <- function(uni){
    if(any(uni$uni_name_source == "publication")){
      return(uni$university_name[uni$uni_name_source == "publication"][1])
    } else if(any(uni$uni_name_source == "other univ where protest occurs")){
      return(uni$university_name[uni$uni_name_source == "other univ where protest occurs"][1])
    } else {
      return(uni$university_name[1])
    }
  }

  umbrella_campaigns <- tar_read(integrated) |>
    mutate(
      # Publication if present, uni where protest occurs if otherwise
      main_university = map_chr(university, pick_university),
    ) |>
    select(
      canonical_id, key, description, publication, start_date,
      location, main_university, issue, racial_issue,
    ) |>
    st_drop_geometry() |>
    mutate(is_umbrella = str_detect(key, "^Umbrella"),
           is_campaign = canonical_id %in% campaigns,
           across(where(is.list), ~map_chr(., ~paste0(.[. != "_Not relevant"], collapse = ", "))))
  # umbrella_campaigns |>
  #   group_by(is_umbrella, is_campaign) |>
  #   count()

  lst(
    # umbrella_not_campaign = umbrella_campaigns |>
    #   filter(is_umbrella, !is_campaign) |>
    #   select(-is_umbrella, -is_campaign),
    campaign_not_umbrella = umbrella_campaigns |>
      filter(!is_umbrella, is_campaign) |>
      select(-is_umbrella, -is_campaign)
    ) |>
    writexl::write_xlsx("docs/data-cleaning-requests/campaign_umbrellas.xlsx")


}
