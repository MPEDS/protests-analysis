#' Downloads GLUED dataset https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/P0D1KE
#' Tracks university names and enrollment counts globally, and for us is especially
#' useful to track Canadian universities
#'
#' URL is again not managed through targets because the ETag or Last-Modified
#' headers aren't present on this resource
get_glued <- function(){

  glued <- read_dta(
    "https://borealisdata.ca/api/access/datafile/424713?format=original&gbrecs=true"
  ) |>
    filter(country == "canada") |>
    mutate(private = case_when(private01 == 1 ~ TRUE,
                                private01 == 0 ~ FALSE,
                                TRUE ~ NA)) |>
    select(
      uni_name = orig_name,
      glued_id = iau_id1,
      phd_granting,
      private,
      enrollment_count = students5_estimated
    )

  return(glued)
}
