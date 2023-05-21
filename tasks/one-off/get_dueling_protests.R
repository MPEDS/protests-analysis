get_dueling_protests <- function(){
  issue_pairs <- list(
    Trump = c("Trump and/or his administration \\(For\\)",
      "Trump and/or his administration \\(Against\\)"),
    "Far Right" = c("Far Right/Alt Right \\(For\\)",
      "Far Right/Alt Right \\(Against\\)"),
    "Speech" = c("Free speech",
      "Anti-racism|Hate speech"),
    "Palestine" = c("Pro-Israel/Zionism",
      "Pro-Palestine/BDS"),
    "LGBT" = c("(LGB\\+/Sexual orientation \\(Against\\))|(Traditional marriage/family)",
      "LGB\\+/Sexual orientation \\(For\\)"),
    "Trans rights" = c("Transgender issues \\(Against\\)",
      "Transgender issues \\(For\\)"),
    "Police violence" = c("Police violence",
      "(Pro-law enforcement)|(All Lives Matter)"),
    "Immigration" = c("Immigration \\(Against\\)",
      "Immigration \\(For\\)"
    ),
    "Abortion" = c("Abortion access", "Abortion \\(Against\\)/Pro-life")
  )

  mpeds <- tar_read(integrated)
    st_drop_geometry() |>
    mutate(
      issue = map(issue, \(issue_grp){
        issue_grp |> str_replace("LGB\\+/Sexual orientation$", "LGB+/Sexual orientation (For)")
      })
    )

  event_details <- mpeds |>
    select(key, description, issue, racial_issue)

  keys <- mpeds |>
    select(canonical_id, key) |>
    distinct()
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  canonical_event_relationship <- canonical_event_relationship |>
    mutate(relationship_type = paste0("Has as ", relationship_type)) |>
    rename(canonical_id1 = canonical_id2, canonical_id2 = canonical_id1) |>
    bind_rows(
      mutate(canonical_event_relationship,
             relationship_type = paste0(relationship_type, " event for"))
    ) |>
    left_join(keys, by = c("canonical_id2" = "canonical_id")) |>
    rename(related_keys = key) |>
    left_join(keys, by = c("canonical_id1" = "canonical_id")) |>
    select(-canonical_id2, -canonical_id1) |>
    group_by(key, relationship_type) |>
    summarize(related_keys = paste0(related_keys, collapse = ", "),
              .groups = "drop") |>
    pivot_wider(names_from = relationship_type, values_from = related_keys)

  get_dueling_protest <- function(pair){
    mpeds |>
      select(key, start_date, university, issue, racial_issue) |>
      pivot_longer(cols = c(issue, racial_issue),
                   values_to = "dueling_issue") |>
      select(-name) |>
      unnest(dueling_issue) |>
      group_by(start_date, university) |>
      # keep rows if are in one of the two dueling protest groups
      # AND at least one from each issue is present across the group at large
      # (the group being the start date - university combination)
      filter(str_detect(dueling_issue, pair[1]) | str_detect(dueling_issue, pair[2]),
             any(str_detect(dueling_issue, pair[1])),
             any(str_detect(dueling_issue, pair[2]))) |>
      arrange(start_date, university, dueling_issue) |>
      left_join(event_details, by = "key") |>
      mutate(
        across(c(issue, racial_issue),
               ~map_chr(., function(x){paste0(x, collapse = ", ")}))
      ) |>
      left_join(canonical_event_relationship, by = "key")
  }

  issue_pairs |>
    map(get_dueling_protest) |>
    set_names(names(issue_pairs))
}

# Pull anti-alt-right protests to see if we're missing any that match up
# to Charlottesville protests
get_altright_against <- function(){
  mpeds <- tar_read(integrated) |> st_drop_geometry()

  altright_against <- mpeds |>
    filter(
      start_date < as.Date("2017-08-31"),
      start_date > as.Date("2017-08-11"),
      map_lgl(issue, ~"Far Right/Alt Right (Against)" %in% .)
    ) |>
    select(key, start_date, issue, racial_issue) |>
    arrange(start_date) |>
    mutate(across(c(issue, racial_issue), ~map_chr(., function(x){paste0(x, collapse = ", ")})))

  # 33 events in Charlottesville, but none in 2017 or 2018
  charlottesville <- mpeds |>
    filter(location == "Charlottesville, VA, USA" | str_detect(key, "Charlottesville")) |>
    select(key, start_date, issue, racial_issue) |>
    arrange(start_date) |>
    filter(year(start_date) == 2017) |>
    mutate(across(c(issue, racial_issue), ~map_chr(., function(x){paste0(x, collapse = ", ")})))

  list(
    "Anti-Alt-Rights, Aug 11-31 2017" = altright_against,
    "2017 Charlottesville protests" = charlottesville
  )
}
