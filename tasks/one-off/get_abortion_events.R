get_abortion <- function(){
  tar_read(integrated) |>
    st_drop_geometry() |>
    mutate(abortion_issue = issue) |>
    select(key, description, form, abortion_issue, racial_issue, issues_text, issue) |>
    unnest(abortion_issue) |>
    filter(str_detect(abortion_issue, "Abort")) |>
    mutate(across(where(is.list), ~map_chr(., \(x){paste0(x, collapse = ", ")}))) |>
    select(key, abortion_issue, everything())
}
