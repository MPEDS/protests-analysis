#' Processes the raw/imported coder table
#' @param canonical_events The target created by get_canonical_events.
#' @param uni_pub_xwalk_file Target of the same name. Parameterized
#' because `targets` keeps track of
#' @return A "wide" version of the table, meaning
#' each row is a single event-article combination
#' and variables are a single column.
#' Obligatory: read "tidy data" for goals http://vita.had.co.nz/papers/tidy-data.html
process_canonical_events <- function(canonical_events, uni_pub_xwalk_file){
  uni_pub_xwalk <- read_csv(uni_pub_xwalk_file, show_col_types = FALSE)

  wide <- canonical_events |>
    select(-event_id, -cec_id) |>
    mutate(
      across(where(is.character), str_trim),
      value = case_when(
        !is.na(text) ~ text,
        variable == "location" & str_detect(value, "(V|v)irtual") ~ NA_character_,
        TRUE ~ value
      )
    ) |>
    # necessary to hard-code to exclude canonical events
    # with two (equivalent) locations
    filter(!(key == "20130918_AnnArbor_Demonstration_ProChoice" &
               value == "Ann Arbor, Michigan, USA")
    ) |>
    select(-text) |>
    distinct() |>
    mutate(
      # variable = case_when(
      # str_detect(variable, "-text") &&
      #   (str_remove_all(variable, "-text") %in% unique(.data$variable)) ~
      #   str_replace_all(variable, "-text", "-select")
      #   ),
           variable = str_replace_all(variable, '-', '_')) |>  # |>
             # str_remove_all("_text")) |>
    pivot_wider(names_from = variable,
                values_from = value,
                values_fn = list) |>
    # This is a bit strange -- some rows have NAs in the `variable` column,
    # which creates a column labeled `NA` after the pivot
    # But we can't use `filter()` before the pivot to remove them as
    # might be considered idiomatic, since that would remove
    # many events completely and distort our counts of events. So I remove
    # just the column after pivoting.
    select(-`NA`) |>
    mutate(across(where(is_list), \(col){
      # remove NAs -- we want to drop NAs of the form c("Toledo, OH, USA", NA)
      col <- map(col, \(vec){
        if(is.null(vec)) return(vec)
        return(vec[!is.na(vec)])
      })
      # if all the list items in the col have length 1
      if(all(unlist(unique(map(col, length))) <= 1)){
        # and it's not a list of tbls
        classes <- unlist(map(col, class))
        if("tbl" %in% classes) return(col)
        # then this should just be a regular vector
        col_vector <- map(col, \(item){
          ifelse(is.null(item), NA, item)
        }) |> unlist()
        return(col_vector)
      }
      return(col) # and otherwise just return col
    }))

  # creating a university column based off of the publication name
  # partly to help with geocoding as a stand-in for the actual location
  # also does cleaning of the university names variable itself
  with_unis <- wide |>
    filter(nchar(key) > 0, !is.na(key)) |>
    mutate(publication = str_replace_all(publication, " ", "-"),
           pub_uni = publication |>
             str_extract(":-.*$") |>
             str_remove(":-") |>
             str_replace_all("([A-Za-z])(?=-)", "\\1 ") |>
             str_remove_all("-") |>
             str_replace("St Michael.*", "St Michael's College"),
           university_names_text = map(university_names_text,
                                  ~str_remove_all(., "(,|\\.|')$") |>
                                    str_trim())) |>
  # around 7k/35k don't match because they dont fit the above patterns,
  # so we use this hand-coded table for university-publication matching
    left_join(uni_pub_xwalk, by = c("publication" = "pub")) |>
    mutate(
      # use uni when pub_uni is not available; uni contains
      # manual corrections I made
      pub_uni = ifelse(is.na(pub_uni), uni, pub_uni) |>
        as.list()
    ) |>
    rename(
      "other univ where protest occurs" = university_names_text,
    ) |>
    pivot_longer(cols = c(
      `other univ where protest occurs`, participating_universities_text, pub_uni
      ), names_to = "uni_name_source", values_to = "university_name") |>
    unnest(cols = c(university_name)) |>
    mutate(university_name = str_remove_all(university_name, ",") |> str_trim(),
           uni_name_source = if_else(uni_name_source == "pub_uni", "publication", uni_name_source)
           ) |>
    nest(university = c(uni_name_source, university_name)) |>
    nest_filter(university, !is.na(university_name)) |>
    select(-uni) |>
    # Some issues have strange presets / existing data problems
    mutate(racial_issue = map(racial_issue, \(issue_list){
      issue_list |>
        str_trim() |>
        str_replace_all("Indigenous Issues", "Indigenous issues") |>
        unique()
    }), start_date = map_chr(start_date, ~ifelse(is.null(.), NA_character_, .[1]))
    )

  # converting yes/no columns to lgl
  is_yesno <- function(col){
    if(!is.character(col)) return(FALSE)
    col |>
      map_lgl(\(cell){
        cell %in% c("yes", NA_character_)
      }) |>
      all()
  }

  with_bools <- with_unis |>
    mutate(across(where(is_yesno), ~map_lgl(., \(x) isTRUE(x == "yes"))),
           # converts yes/NA -> TRUE/FALSE,
           )

  return(with_bools)
}

