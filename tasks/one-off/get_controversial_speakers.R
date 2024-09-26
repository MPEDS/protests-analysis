


get_controversial_speakers <- function() {

  tar_load(integrated)

  integrated <- integrated |>
    st_drop_geometry()

  controverisal <- integrated |>
    filter(map_lgl(target_text, ~any(str_detect(., "Planned Parenthood")))) |>
    select(canonical_id, key, issue, issues_text, target, target_text) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

}
