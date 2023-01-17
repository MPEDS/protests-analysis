#' attach MPEDS names to IPEDS and GLUED names, based on the cleaned
#' and verified crosswalk
match_uni_names <- function(ipeds, glued, mpeds, xwalk_filename){
  xwalk <- read_csv(xwalk_filename, show_col_types = FALSE) |>
    select(original_name, authoritative_name) |>
    drop_na(authoritative_name) |>
    distinct()

  ipeds <- ipeds |>
    select(name, id) |>
    distinct()

  matched_xwalk <- xwalk |>
    left_join(ipeds, by = c(true_name = "name"))

  return(matched_xwalk)
}
