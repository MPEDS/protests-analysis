read_googlesheet <- function(document_id, sheet = 1){
  base_url <- "https://docs.google.com/spreadsheets/d/"
  url <- paste0(base_url, document_id)
  path <- drive_download(url, tempfile())$local_path
  path |>
    excel_sheets() |>
    set_names() |>
    map(read_excel, path = path)
}
