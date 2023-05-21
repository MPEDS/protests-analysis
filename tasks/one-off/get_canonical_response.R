get_canonical_response <- function(){
  # adjudicator, key, start date, location, univ, event description, racial/issue
  canonical_events <- tar_read(canonical_events)
  con <- connect_sheriff()
  user <- tbl(con, "user") |>
    collect() |>
    select(-password, -authlevel, adjudicator = username)

  mpeds <- tar_read(integrated) |>
    st_drop_geometry() |>
    select(key, adjudicator_id, start_date, location, university, description,
           racial_issue, issue,
           university_action_on_issue, university_discourse_on_issue) |>
    pivot_longer(cols = c(university_action_on_issue, university_discourse_on_issue)) |>
    unnest(value) |>
    filter(
      !(name == "university_action_on_issue" & value == "Action in Process"),
      !(name == "university_discourse_on_issue" & value != "Apology/Responsibility"),
      value != "NA/Unclear"
    ) |>
    left_join(user, by = c("adjudicator_id" = "id")) |>
    mutate(across(c(racial_issue, issue),
             ~map_chr(., \(item){
               paste0(item[item != "_Not relevant"], collapse = ", ")
               })),
           value = str_replace(value, "/", " or ")) |>
    select(-name, -adjudicator_id) |>
    rename(category = value)

  mpeds <- mpeds |>
    group_by(key) |>
    slice_head(n = 1) |>
    mutate(category = "All") |>
    bind_rows(mpeds) |>
    group_by(category)

  mpeds |>
    group_split() |>
    set_names(group_data(mpeds)$category)
}
