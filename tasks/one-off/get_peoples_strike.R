


get_peoples_strike <- function() {

  integrated <- tar_read(integrated)

  tuition_strike <- integrated |>
    st_drop_geometry() |>
    filter(if_any(where(is.character), ~ str_detect(str_to_lower(.), "tuition strike|student strike"))) |>
    select(key, description, start_date, end_date, location,
           form, issue, issues_text, target, target_text,
           size_text, university_responses_text, university_reactions_to_protest) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))


  writexl::write_xlsx(tuition_strike,
                      "docs/data-cleaning-requests/tuition_strike.xlsx")

}
