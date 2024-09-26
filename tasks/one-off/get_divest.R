get_divest <- function(){
  con <- connect_sheriff()
  article_xwalk <- tbl(con, "coder_event_creator") |>
    select(id, article_id, event_id) |>
    left_join(tbl(con, "canonical_event_link") |>
                select(canonical_id, cec_id), by = c("id" = "cec_id")) |>
    select(article_id, canonical_id) |>
    distinct() |>
    left_join(tbl(con, "article_metadata"), by= c("article_id" = "id")) |>
    select(canonical_id, text) |>
    collect() |>
    group_by(canonical_id) |>
    summarize(article_text = list(text))


  pick_university <- function(uni){
    if(any(uni$uni_name_source == "publication")){
      return(uni$university_name[uni$uni_name_source == "publication"][1])
    } else if(any(uni$uni_name_source == "other univ where protest occurs")){
      return(uni$university_name[uni$uni_name_source == "other univ where protest occurs"][1])
    } else {
      return(uni$university_name[1])
    }
  }
  integrated |>
    st_drop_geometry() |>
    mutate(canonical_id = as.integer(canonical_id)) |>
    left_join(article_xwalk, by = "canonical_id") |>
    mutate(description_has_divest = str_detect(str_to_lower(description), "divest"),
           article_text_has_divest = map_lgl(article_text, ~any(str_detect(str_to_lower(.), "divest")))) |>
    filter(article_text_has_divest, !description_has_divest) |>
    mutate(
      # Publication if present, uni where protest occurs if otherwise
      main_university = map_chr(university, pick_university),
    ) |>
    select(
      canonical_id, key, description, publication, start_date,
      location, main_university, issue, racial_issue, article_text,
    ) |>
    st_drop_geometry() |>
    unnest(cols = article_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste0(.[. != "_Not relevant"], collapse = ", ")))) |>
    writexl::write_xlsx("docs/data-cleaning-requests/divest.xlsx")
}
