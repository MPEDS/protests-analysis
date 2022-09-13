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

  canonical_events <- canonical_events %>%
    select(-event_id, -cec_id) %>%
    mutate(
      across(where(is.character), str_trim),
      value = case_when(
        !is.na(text) ~ text,
        TRUE ~ value
      )
    ) %>%
    filter(!(variable == "location" & str_detect(value, "(V|v)irtual"))) %>%
    select(-text)

  wide <-  canonical_events %>%
    distinct() %>%
    mutate(variable = str_replace_all(variable, '-', '_') %>%
             str_remove_all("_text")) %>%
    pivot_wider(names_from = variable,
                values_from = value,
                values_fn = list)  %>%
    mutate(across(where(is_list), \(col){
      # if all the list items in the col have length 1
      if(all(unlist(unique(map(col, length))) <= 1)){
        # and it's not a list of tbls
        classes <- unlist(map(col, class))
        if("tbl" %in% classes) return(col)
        # then this should just be a regular vector
        col_vector <- map(col, \(item){
          ifelse(is.null(item), NA, item)
        }) %>% unlist()
        return(col_vector)
      }
      return(col) # and otherwise just return col
    }))

  # creating a university column based off of the publication name
  # partly to help with geocoding as a stand-in for the actual location
  # also does cleaning of the university names variable itself
  with_unis <- wide %>%
    mutate(publication = str_replace_all(publication, " ", "-"),
           pub_uni = publication %>%
             str_extract(":-.*$") %>%
             str_remove(":-") %>%
             str_replace_all("([A-Za-z])(?=-)", "\\1 ") %>%
             str_remove_all("-") %>%
             str_replace("St Michael.*", "St Michael's College"),
           university_names = map(university_names,
                                  ~str_remove_all(., "(,|\\.|')$") %>%
                                    str_trim())) %>%
  # around 7k/35k don't match because they dont fit the above patterns,
  # so we use this hand-coded table for university-publication matching
    left_join(uni_pub_xwalk, by = c("publication" = "pub")) %>%
    mutate(
      # use pub_uni when uni is not available; pub_uni contains
      # manual corrections I made
      university = ifelse(is.na(pub_uni), uni, pub_uni),
      # use university_names, which coders annotated, when available
      university = map2(university_names, university,
                        function(uni_name, uni){
                          ifelse(length(uni_name) == 0L,
                               uni, uni_name)
                          })) %>%
    select(-uni, -pub_uni, -university_names)

  # converting yes/no columns to lgl
  is_yesno <- function(col){
    if(!is.character(col)) return(FALSE)
    col %>%
      map_lgl(\(cell){
        cell %in% c("yes", NA_character_)
      }) %>%
      all()
  }

  with_bools <- with_unis %>%
    mutate(across(where(is_yesno), ~map_lgl(., \(x) isTRUE(x == "yes"))),
           # converts yes/NA -> TRUE/FALSE,
           )

  return(with_bools)
}
