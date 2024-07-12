#' Downloads GLUED dataset https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/P0D1KE
#' Tracks university names and enrollment counts globally, and for us is especially
#' useful to track Canadian universities
#'
#' URL is again not managed through targets because the ETag or Last-Modified
#' headers aren't present on this resource
get_glued <- function(){
  filename <- tempfile()
  drive_auth_configure(api_key = Sys.getenv("GCP_API_KEY"))
  drive_deauth()
  drive_download("https://docs.google.com/spreadsheets/d/1dpogHTjbYa1Omvw-nSuXVt5JNRyu1dV6/",
                 filename)

  readxl::read_excel(filename)
}

clean_glued <- function(glued_raw){
  glued_clean <- glued_raw |>
    filter(country == "canada", is.na(yrclosed),
           orig_name != "", year %in% c(2010, 2015, 2020)) |>
    mutate(across(c(private01, phd_granting, b_granting, m_granting),
                  function(x){
                    case_when(x == 1 ~ TRUE,
                              x == 0 ~ FALSE,
                              TRUE ~ NA)
                  })) |>
    select(
      uni_name = eng_name,
      uni_id = iau_id1,
      phd_granting,
      bachelors_granting = b_granting,
      masters_granting = m_granting,
      private = private01,
      enrollment_count = students5_estimated,
      year
    )

  # GLUED only provides data for colleges in 5-year intervals,
  # so we have to interpolate the data between 2010 and 2020
  # before restricting to the 2012-2018 range
  # For numeric variables, we take the average;
  # for binary variables, we take the most recent
  # so "is_uni_public" for 2017 would be the 2015 value, for 2014 it would be
  # the 2010 value, etc
  glued_year_skeleton <- expand_grid(
    uni_id = unique(glued_clean$uni_id),
    year = 2011:2018
    )

  glued_interpolated <- glued_clean |>
    # Initial interpolation to get bachelors' and masters' degree
    # granting status in 2010, when most are missing (?) --
    group_by(uni_id) |>
    mutate(across(c(bachelors_granting, masters_granting),
                  ~ifelse(is.na(.), lead(.), .))) |>
    full_join(glued_year_skeleton, by = join_by(uni_id, year)) |>
    arrange(uni_id, year) |>
    fill(where(is.character) | where(is.logical)) |>
    mutate(across(where(is.numeric), ~na.approx(., na.rm = F)))

  return(glued_interpolated)
}
