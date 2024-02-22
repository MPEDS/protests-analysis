read_googlesheet <- function(document_id, sheet = NULL){
  base_url <- "https://docs.google.com/spreadsheets/d/"
  url <- paste0(base_url, document_id)
  path <- drive_download(url, tempfile())$local_path
  sheet_names <- path |>
    excel_sheets()

  if(is.null(sheet)){
    map(1:length(sheet_names),
        \(i){read_excel(path, sheet = i)}) |>
      set_names(sheet_names)
  } else {
    read_excel(path, sheet = sheet)
  }
}
