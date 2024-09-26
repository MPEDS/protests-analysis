get_divest <- function(){
  source("tasks/mpeds/import/connect_sheriff.R")
  source("tasks/utils/get_key_variables.R")
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


  integrated |>
    get_key_variables(university) |>
    left_join(article_xwalk, by = "canonical_id") |>
    mutate(description_has_divest = str_detect(str_to_lower(description), "divest")) |>
    filter(!description_has_divest) |>
    mutate(
      # Publication if present, uni where protest occurs if otherwise
      main_university = map_chr(university, pick_university),
    ) |>
    # Annoying excel thing, only affects one event
    filter(map_lgl(article_text, ~!any(str_length(.) > 32767))) |>
    unnest(cols = article_text) |>
    filter(str_detect(str_to_lower(article_text), "divest")) |>
    writexl::write_xlsx("docs/data-cleaning-requests/divest.xlsx")
}
