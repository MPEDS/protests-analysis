# Pull up all canonical events with Planned Parenthood text select for Target.
# Cleaning: Check that Planned Parenthood (text select)
# is coded as Target: Medical organization and Target: Non-governmental org

get_planned_parenthood <- function(){

  tar_load(integrated)

  integrated <- integrated |>
    st_drop_geometry()

  pp_target_text <- integrated |>
    filter(map_lgl(target_text, ~any(str_detect(., "Planned Parenthood")))) |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  pp_issues_text <- integrated  |>
    filter(map_lgl(issues_text, ~any(str_detect(., "Planned Parenthood")))) |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  pp_any_field <- integrated |>
    rowwise() |>
    filter(any(str_detect(c_across(where(is.character)), regex("Planned Parenthood", ignore_case = TRUE)))) |>
    ungroup() |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  writexl::write_xlsx(lst(pp_target_text, pp_issues_text, pp_any_field),
                      "docs/data-cleaning-requests/low-level-data-cleaning/planned_parenthood_targets.xlsx")
}
