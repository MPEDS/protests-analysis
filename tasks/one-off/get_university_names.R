#' Get integrated university names
#'
#' @returns A dataframe with columns key,location,description, uni_name

get_university_names <- function() {

  integrated <- tar_read(integrated)

  uni_name_integrated <- integrated |>
    st_drop_geometry() |>
    unnest(cols = c(university), names_repair = "minimal") |>
    select(key,location,description, uni_name) |>
    filter(is.na(uni_name))

  return(uni_name_integrated)
}
