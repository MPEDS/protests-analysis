# Pull up all canonical events with Target text select:
#   - Janet Napolitano,
#   - David Petraeus,
#   - Condoleezza Rice,
#   - Margaret Spellings

get_government_officials <- function() {

  tar_load(integrated)

  integrated <- integrated |>
    st_drop_geometry()

  gov_officials <- integrated |>
    filter(map_lgl(target_text, ~any(str_detect(., "Janet Napolitano|David Petraeus|Condoleezza Rice|Margaret Spellings")))) |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  writexl::write_xlsx(gov_officials,
                      "docs/data-cleaning-requests/low-level-data-cleaning/gov_official_targets.xlsx")
  return(gov_officials)
}
