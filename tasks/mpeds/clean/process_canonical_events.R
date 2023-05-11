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
      # use pub_uni when uni is not available; pub_uni contains
      # manual corrections I made
      university = ifelse(is.na(pub_uni), uni, pub_uni),
      # use university_names, which coders annotated, when available
      university = map2(university_names_text, university,
                        function(annotated_uni, publication_uni){
                          if(length(annotated_uni) > 0){
                            return(annotated_uni)
                          } else {
                            return(publication_uni)
                          }
                          }),
      uni_name_source = map_chr(
        university_names_text,
        ~ifelse(length(.) > 0, "other univ where protest occurs", "publication")
      )) |>
    select(-uni, -pub_uni, -university_names_text) |>
    # Some issues have strange presets
    mutate(racial_issue = map(racial_issue, \(issue_list){
      issue_list |>
        str_trim() |>
        str_replace_all("Indigenous Issues", "Indigenous issues") |>
        str_replace_all("LGB+/Sexual orientation$", "LGB+/Sexual orientation (For)") |>
        unique()
    }))

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

