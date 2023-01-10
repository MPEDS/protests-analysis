#' Export the canonical events and Elephrame datasets in a way so that the `size` variable
#' can be processed by the Python mpeds/mpeds/open_ended_coder.py script
#' and then by human coders

#' What happens between this function and the processing is out of scope for
#' `targets` for now, because it 1) relies on code not managed by it and 2)
#' relies on non-manageable human inputs
#'
export_size <- function(canonical_events, blm){
  articles <- get_articles()
  articles <- articles |>
    select(article_id = id, event_id, title, full_text = text) |>
    filter(!is.na(event_id))
  canonical_events |>
    filter(variable == "size-text") |>
    left_join(articles, by = "event_id") |>
    select(article_id, canonical_key = key, title, full_text, text) |>
    mutate(text = str_to_lower(text)) |>
    distinct() |>
    write_csv("tasks/mpeds/hand/size_raw.csv")

  blm <- blm |>
    st_drop_geometry() |>
    as_tibble()

  # The Elephrame BLM dataset has

  blm |>
    select(url, desc, text = num) |>
    mutate(
      # Filler characters
      parsed = text |> str_remove_all(" \\(\\.est\\)") |>
        str_remove_all(" \\(est\\.\\)") |>
        str_remove_all("\\+") |>
        str_remove_all("≥") |>
        str_trim(),
      # Missingness
      parsed = if_else(
        str_detect(parsed, "Unclear|--|x|TBD|Varied"),
        NA_character_,
        parsed),
      # semantic words
      parsed = parsed |>
        str_replace_all("Dozens", "36") |>
        str_replace_all("Hundreds", "150") |>
        str_replace_all("Thousands", "1500"),
      # ranges
      parsed = map_chr(parsed, function(x){
        if(is.na(x)) return(x)
        if(!str_detect(x, "-")) return(x)
        str_split(x, "-") |>
          unlist() |>
          str_trim() |>
          as.numeric() |>
          mean() |>
          as.character()
      }),
    ) |>
    select(url, desc, raw = text, parsed) |>
    write_csv("tasks/mpeds/hand/blm_size.csv")
}


