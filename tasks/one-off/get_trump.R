get_trump <- function(){
  # The fields I need are:
  # Key, Description, Start Date, End Date,  Location, Form, Issue, Racial Issue,
  #Issue Text-Select, Target, Target Text-Select, Government Officials.

  tar_load(integrated)
  integrated |>
    st_drop_geometry() |>
    filter(map_lgl(issue, ~any(str_detect(., "Trump")))) |>
    select(key, description, start_date, end_date,
           location, form, issue, racial_issue, issues_text,
           target, target_text, government_officials_text) |>
    mutate(across(where(is.list), ~map_chr(., \(x){paste0(sort(x), collapse = ", ")})),
           trump_issue = ifelse(map_lgl(issue, ~any(str_detect(., "Trump.*Against"))),
                                "Against Trump",
                                "For Trump"
                                )
             ) |>
    select(key, trump_issue, everything())
}
