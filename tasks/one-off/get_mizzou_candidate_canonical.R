# stuff to pull:

  #

  # university-reactions-to-protest
  # university-discourse-on-protest
  # university-action-on-issue
  # university-discourse-on-issue

# pulling table from SQL to R so we can View()
# tbl(con, "coder_event_creator")

get_mizzou_candidate_canonical <- function(){
  con <- connect_sheriff()
  coder_event_creator <- tbl(con, "coder_event_creator") |>
    collect() |>
    # if text exists, use it as value
    mutate(value = case_when(!is.na(text) ~ text,
                             T ~ value)) |>
    select(article_id, event_id, variable, value) |>
    pivot_wider(names_from = variable) |>
    filter(location %in% c("Columbia, MO, USA", "Columbia, Missouri, USA"),
          `start-date` >= "2015-08-01",
          `end-date` <= "2016-06-20")

  articles <- tbl(con, "article_metadata") |>
    select(id, pub_date) |>
    collect()

  clean_candidate <- coder_event_creator |>
    select(event_id,
           desc,
           `start-date`,
           form,
           issue,
           article_id,
           `university-responses-text`,
           `university-reactions-to-protest`,
           `university-discourse-on-protest`,
           `university-action-on-issue`,
           `university-discourse-on-issue`) |>
    left_join(articles, by = c("article_id"="id")) |>
    # KEEP EMPTY after unnesting. new number of rows should be greater than before
    unnest(`university-responses-text`, keep_empty = TRUE) |>
    # PASTE changes c("Palestine", "anti-racism")  -> "Palestine, anti-racism"
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ","))))

  clean_canonical <- tar_read(integrated) |>
    st_drop_geometry() |>
    filter(location == "Columbia, MO, USA",
           start_date >= "2015-08-01",
           end_date <= "2016-06-20") |>
    select(key, start_date, form, issue,
           university_responses_text,
           university_reactions_to_protest,
           university_discourse_on_protest,
           university_action_on_issue,
           university_discourse_on_issue) |>
    # KEEP EMPTY after unnesting. new number of rows should be greater than before
    unnest(`university_responses_text`, keep_empty = TRUE) |>
    # PASTE changes c("Palestine", "anti-racism")  -> "Palestine, anti-racism"
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ","))))

  writexl::write_xlsx(lst(clean_candidate, clean_canonical),
                      "docs/data-cleaning-requests/mizzou_candidate_canonical.xlsx")
}
