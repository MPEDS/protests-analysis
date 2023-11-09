# Logic to
# 1) Acquire counts, total counts of campaigns, by year by issue
# 2) subset of campaigns between 2014-2015 maybe
get_campaigns_counts <- function(){
  con <- connect_sheriff()
  campaigns <- tbl(con, "canonical_event_relationship") |>
    filter(relationship_type == "campaign") |>
    select(canonical_id = canonical_id1,
           campaign_id = canonical_id2) |>
    collect()

  events <- tar_read(integrated) |>
    st_drop_geometry() |>
    left_join(campaigns, by = "canonical_id")

  by_year <- events |>
    select(campaign_id, year) |>
    distinct() |>
    filter(!is.na(year), !is.na(campaign_id)) |>
    group_by(year) |>
    count()

  by_year_issue <- events |>
    select(campaign_id, year, issue) |>
    unnest(cols = issue) |>
    filter(issue != "_Not relevant",
           !is.na(campaign_id), !is.na(year)) |>
    group_by(year, issue) |>
    count() |>
    ungroup() |>
    pivot_wider(names_from = year, values_from = n,
                values_fill = 0) |>
    arrange(issue)

  by_year_racial_issue <- events |>
    select(campaign_id, year, racial_issue) |>
    unnest(cols = racial_issue) |>
    filter(racial_issue != "_Not relevant",
           !is.na(campaign_id), !is.na(year)) |>
    group_by(year, racial_issue) |>
    count() |>
    ungroup() |>
    pivot_wider(names_from = year, values_from = n,
                values_fill = 0) |>
    arrange(racial_issue)

  return(lst(
    by_year, by_year_issue, by_year_racial_issue
  ))
}

get_campaign_subset <- function(){
  con <- connect_sheriff()
  campaigns <- tbl(con, "canonical_event_relationship") |>
    filter(relationship_type == "campaign") |>
    select(canonical_id = canonical_id1,
           campaign_id = canonical_id2) |>
    collect()

  tar_load(cluster_inputs)
  tar_load(cluster_campaigns)
  tar_load(integrated)
  clusters <- cluster_inputs |>
    mutate(cluster_id = cluster_campaigns$clusters[[1]]) |>
    select(key, cluster_id)

  keys <- integrated |>
    st_drop_geometry() |>
    drop_na(canonical_id) |>
    select(campaign_id = canonical_id,
           campaign_key = key)

  events <- integrated |>
    st_drop_geometry() |>
    filter(year == 2014 | year == 2015) |>
    left_join(campaigns, by = "canonical_id") |>
    left_join(clusters, by = "key") |>
    left_join(keys, by = "campaign_id") |>
    select(key,
           campaign_key,
           cluster_id,
           location,
           description,
           start_date,
           university_action_on_issue,
           university_discourse_on_issue,
           university_reactions_to_protest,
           university_discourse_on_protest,
           issue,
           racial_issue,
           ) |>
    drop_na(start_date) |>
    arrange(start_date) |>
    mutate(across(where(is.list), ~map_chr(., \(x){paste0(sort(x), collapse = ", ")})))
}
