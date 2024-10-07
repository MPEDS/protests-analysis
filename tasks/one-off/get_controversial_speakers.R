


get_controversial_speakers <- function() {

  tar_load(integrated)

  integrated <- integrated |>
    st_drop_geometry()

  controversial_speakers <- integrated |>
    filter(
      map_lgl(description, ~any(str_detect(., "Milo Yiannopoulos|Ann Coulter|Richard Spencer|Charles Murray|Gavin McInnes|Ezra Levant|Heather MacDonald|Jordan Peterson"))) |
      map_lgl(issues_text, ~any(str_detect(., "Milo Yiannopoulos|Ann Coulter|Richard Spencer|Charles Murray|Gavin McInnes|Ezra Levant|Heather MacDonald|Jordan Peterson")))) |>
    select(canonical_id, key, description, issue, issues_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))


  writexl::write_xlsx(controversial_speakers,
                      "docs/data-cleaning-requests/low-level-data-cleaning/controversial_speakers.xlsx")
}
