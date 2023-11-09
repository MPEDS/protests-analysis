get_2015_racial <- function(){

  solidarity_links <- tar_read(canonical_event_relationship) |>
    filter(relationship_type == "solidarity")

  cleaned_events <- tar_read(cleaned_events)
  keys <- cleaned_events |>
    select(canonical_id, key)
  solidarity_links <- solidarity_links |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    group_by(canonical_id1) |>
    summarize(solidarity_link = paste0(key, collapse = ", "))

  events <- cleaned_events |>
    filter(
      start_date > "2015-08-01", start_date < "2016-07-01",
      map_lgl(racial_issue, ~!all(.=="_Not relevant"))
    ) |>
    mutate(across(c(issue, racial_issue), ~map_chr(., \(x){paste0(x, collapse = ", ")})),
           university = map_chr(university, ~.[1])) |>
    left_join(solidarity_links, by = c("canonical_id" = "canonical_id1")) |>
    select(key, university, solidarity_link, description, publication, start_date, location,
           issue, racial_issue
           )

  return(events)
}
