#' Processes the raw/imported coder table
#' @param coder_table The target outputted by get_coder_table.
#' @return A "wide" version of the table, meaning
#' each row is a single event-article combination
#' and variables are a single column.
#' Obligatory: read "tidy data" for goals http://vita.had.co.nz/papers/tidy-data.html
#'
#' In the process, cleans up some locations by inserting university names
#' when location names are suspect

process_coder_table <- function(coder_table, uni_pub_xwalk_file){
  uni_pub_xwalk <- read_csv(uni_pub_xwalk_file, show_col_types = FALSE)
  base <- coder_table %>%
    select(-timestamp, -solr_id, -id, -coder_id) %>%
    filter(value != "0") %>%
    unique()

  text_cols <- base %>%
    filter(text != "0") %>%
    nest(text = c(variable, value, text))

  wide <- base %>%
    filter(text == "0") %>%
    select(-text) %>%
    pivot_wider(names_from = variable,
                values_from = value,
                values_fn = list) %>%
    full_join(text_cols, by = c("article_id", "event_id", "publication", "pub_date")) %>%
    mutate(across(where(is_list), \(col){
      # if all the list items in the col have length 1
      if(all(unlist(map(col, length)) <= 1)){
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
  with_unis <- wide %>%
    mutate(pub_uni = str_extract(publication, ":-.*$") %>%
             str_remove(":-") %>%
             str_replace_all("([A-Za-z])(?=-)", "\\1 ") %>%
             str_remove_all("-") %>%
             str_replace("St Michael.*", "St Michael's College")) %>%
  # around 7k/35k don't match because they dont fit the above patterns,
  # so we use this hand-coded table for university-publication matching
    left_join(uni_pub_xwalk, by = c("publication" = "pub")) %>%
    mutate(university = ifelse(is.na(pub_uni), uni, pub_uni)) %>%
    select(-uni)

  # converting yes/no columns to lgl
  is_yesno <- function(col){
    if(!is.character(col)) return(FALSE)
    col %>%
      map_lgl(\(cell){
        cell %in% c("yes", NA_character_)
      }) %>%
      all()
  }

  with_unis %>%
    mutate(across(where(is_yesno), ~map_lgl(., \(x) isTRUE(x == "yes"))),
           # yes/NA -> TRUE/FALSE,
           )

  # still some problems lol
  # map(wide, class) %>% as_tibble %>% pivot_longer(everything())
  # wide %>% filter(unlist(map(`start-date`, ~length(.) > 1)))

  # summary stats
  # how many from original table have locations?
  # coder_table %>% filter(variable == "location") %>% pull(event_id) %>% unique %>% length
  # 17959
  # 48.9% missing (!)

  # how many that aren't 0s?
  # 17790
}

