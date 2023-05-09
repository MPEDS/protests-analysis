get_mizzou_responses <- function(){

  mpeds <- tar_read(integrated) |> st_drop_geometry()
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  # the `canonical_event_relationship` data.frame doesn't expose at first glance
  # children-of-children, so we have to loop through the dataset until
  # we know we've found all of the sub-campaign events
  mizzou_ids <- mpeds |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    pull(canonical_id)

  new_ids <- mizzou_ids
  should_find_events <- TRUE
  while(should_find_events){
    new_events <- tibble(canonical_id2 = new_ids) |>
      inner_join(canonical_event_relationship, by = c("canonical_id2"))
    new_ids <- unique(new_events$canonical_id1)
    mizzou_ids <- unique(c(mizzou_ids, new_ids))
    if(length(new_ids) == 0){
      should_find_events <- FALSE
    }
  }

  mizzou_ids <- unique(mizzou_ids)
  mizzou <- tibble(canonical_id = mizzou_ids) |>
    left_join(mpeds, by = "canonical_id")

  get_response <- function(response_type){
    mizzou |>
      select(key, {{response_type}}) |>
      unnest(cols = {{response_type}}) |>
      filter({{response_type}} != "NA/Unclear") |>
      group_by(key) |>
      summarize({{response_type}} := paste0({{response_type}}, collapse = ", "))
  }

  list(
    "University discourse on issue" = get_response(university_discourse_on_issue),
    "University discourse on protest" = get_response(university_discourse_on_protest),
    "University action on issue" = get_response(university_action_on_issue),
    "University reaction to protest" = get_response(university_reactions_to_protest)
  )
}
