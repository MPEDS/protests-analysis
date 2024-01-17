get_issue_spot_check <- function(){
  tar_load(integrated)

  keys <- integrated |> select(canonical_id, key)
  campaign_keys <- tar_read(canonical_event_relationship) |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    rename(campaign_event = key) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    select(campaign_event, campaign_umbrella = key)

  divestment_campaigns <- integrated |>
    filter(str_detect(key, "Umbrella"), str_detect(key, "Divestment")) |>
    pull(canonical_id)
  divestment_event_ids <- tar_read(canonical_event_relationship) |>
    filter(relationship_type == "campaign", canonical_id2 %in% divestment_campaigns) |>
    pull(canonical_id1) |>
    unique()

  list(
    ontario_labor = integrated |>
      filter(start_date > "2014-07-01", start_date < "2016-06-30",
             str_detect(location, "Ontario|ON,"),
             map_lgl(issue, ~"Labor and work" %in% .)),
    california_labor = integrated |>
      filter(str_detect(location, "CA,|California"),
             map_lgl(issue, ~"Labor and work" %in% .)),
    environmental = integrated |>
      filter(map_lgl(issue, ~"Environmental" %in% .)),
    divestment = integrated |>
      filter(canonical_id %in% divestment_event_ids)
  ) |>
    map(\(dta){
      dta |>
        st_drop_geometry() |>
        left_join(campaign_keys, by = c("key" = "campaign_event")) |>
        select(key, description, campaign_umbrella, start_date, end_date, issue,
               racial_issue, form) |>
        mutate(
          across(where(is.list), ~map(., ~.[.!= "_Not relevant"])),
          across(where(is.list), ~map_chr(., ~paste0(., collapse = ", ")))
        )
    })
}
