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
    "LGBT" = c("(LGB\\+/Sexual orientation)|(Traditional marriage/family)",
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
  mpeds <- tar_read(integrated) |> st_drop_geometry()

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
