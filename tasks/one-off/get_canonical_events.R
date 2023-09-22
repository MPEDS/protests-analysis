# Providing snapshot of canonical events for Ellen and Devin
# start-date, location, form, issue, event description, and adjudicator
# Because adjudicators (and candidate record creators, which I'm adding) are
# on the variable-level and not the canonical event-level, we have to be a bit
# creative about how we present this
# So the code below makes three rows for each event, for values, record creators, and adjudicators
get_canonical_events_adjudicator <- function(){
  keys <- tar_read(integrated) |>
    select(key, cleaned_date = start_date)

  con <- connect_sheriff()
  coders <- tbl(con, "user") |>
    select(id, username)

  canonical_events <- tbl(con, "canonical_event") |>
    left_join(coders, by = c("coder_id" = "id")) |>
    select(key, description, canonical_event_creator = username, canonical_id = id)

  candidate_records <- tbl(con, "coder_event_creator") |>
    left_join(coders, by = c("coder_id" = "id")) |>
    select(cec_id = id, variable, value, text, candidate_record_creator = username)

  links <- tbl(con, "canonical_event_link") |>
    left_join(coders, by = c("coder_id" = "id")) |>
    select(adjudicator = username, canonical_id, cec_id)

  joined <- candidate_records |>
    right_join(links, by = "cec_id") |>
    right_join(canonical_events, by = "canonical_id") |>
    mutate(value = ifelse(!is.na(text), text, value)) |>
    arrange(cec_id) |>
    select(-cec_id, -canonical_id, -text) |>
    collect()

  # Now to present it in a wide-by-variable form -- requires separating adjudicator and
  adjudicators <- joined |>
    select(-candidate_record_creator, -value) |>
    pivot_wider(names_from = "variable", values_from = "adjudicator")
  record_creators <- joined |>
    select(-adjudicator, -value) |>
    pivot_wider(names_from = "variable", values_from = "candidate_record_creator")
  values <- joined |>
    select(-adjudicator, -candidate_record_creator) |>
    pivot_wider(names_from = "variable", values_from = "value")

  combined <- lst(adjudicators, record_creators, values) |>
    bind_rows(.id = "record_type") |>
    mutate(across(where(is.list), \(x){map_chr(x, ~paste(., collapse =", "))}),
           across(where(is.character), str_trim)) |>
    janitor::clean_names() |>
    left_join(keys, by = "key") |>
    arrange(cleaned_date, key, record_type) |>
    select(key, record_type, start_date, location, form, issue, description)

  return(combined)
}
