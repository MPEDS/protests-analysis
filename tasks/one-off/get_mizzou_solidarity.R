get_mizzou_solidarity <- function(){
  canonical_event_relationship <- tar_read(canonical_event_relationship)
  mpeds <- tar_read(integrated)

  con <- connect_sheriff()

  canonical_events <- tbl(con, "canonical_event") |>
    collect()
  mizzou_ids <- canonical_events |>
    filter(key == "Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov") |>
    pull(id)
  direct_links <- canonical_event_relationship |>
    filter(canonical_id2 == mizzou_ids) |>
    pull(canonical_id1) |>
    unique()
  new_ids <- mizzou_ids
  should_find_events <- TRUE
  while(should_find_events){
    new_events <- tibble(canonical_id2 = new_ids) |>
      inner_join(canonical_event_relationship, by = "canonical_id2")
    new_ids <- new_events$canonical_id1 |> unique()
    mizzou_ids <- c(mizzou_ids, new_ids) |> unique()
    if(length(new_ids) == 0){
      should_find_events <- FALSE
    }
  }

  mizzou_ids <- unique(mizzou_ids)

  candidate_events <- tbl(con, "coder_event_creator") |>
    collect()
  canonical_event_link <- tbl(con, "canonical_event_link") |>
    collect()

  merged <- mpeds |>
    filter(canonical_id %in% mizzou_ids,
           !str_detect(key, "^Umbrella")
           ) |>
    select(canonical_id, key, university) |>
    left_join(canonical_event_link, by = "canonical_id") |>
    left_join(candidate_events, by = c("cec_id" = "id")) |>
    st_drop_geometry() |>
    mutate(direct_link = canonical_id %in% direct_links,
           is_link = variable == "link") |>
    select(key, university, event_id, is_link, article_id)
  article_counts <- merged |>
    group_by(key) |>
    summarize(n_articles = length(unique(article_id)),
              article_ids = paste0(unique(article_id), collapse = ", "))

  merged |>
    group_by(key, university, is_link) |>
    summarize(candidate_ids = paste0(unique(event_id), collapse = ", ")) |>
    pivot_wider(names_from = is_link, values_from = candidate_ids)  |>
    rename(manually_linked_candidate_ids = `FALSE`,
           variable_linked_candidate_ids = `TRUE`) |>
    select(-`NA`) |>
    left_join(article_counts, by = "key")
}
