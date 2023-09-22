#' Downloads GLUED dataset https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/P0D1KE
#' Tracks university names and enrollment counts globally, and for us is especially
#' useful to track Canadian universities
#'
#' URL is again not managed through targets because the ETag or Last-Modified
#' headers aren't present on this resource
get_glued <- function(){
  filename <- tempfile()
  drive_auth_configure(api_key = Sys.getenv("GMAPS_API_KEY"))
  drive_deauth()
  drive_download("https://docs.google.com/spreadsheets/d/1dpogHTjbYa1Omvw-nSuXVt5JNRyu1dV6/",
                 filename)

  readxl::read_excel(filename)
}

clean_glued <- function(glued_raw){
  glued_raw |>
    filter(country == "canada", is.na(yrclosed),
           orig_name != "", year == 2015) |>
    mutate(across(c(private01, phd_granting, b_granting, m_granting),
                  function(x){
                    case_when(x == 1 ~ TRUE,
                              x == 0 ~ FALSE,
                              TRUE ~ NA)
                  })) |>
    select(
      uni_name = eng_name,
      glued_id = iau_id1,
      coordinates,
      phd_granting,
      bachelors_granting = b_granting,
      masters_granting = m_granting,
      private = private01,
      enrollment_count = students5_estimated,
      year
    )
}
