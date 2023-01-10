# attach MPEDS names to IPEDS names, based on the cleaned dataset
match_ipeds <- function(ipeds, mpeds, xwalk_filename){
  xwalk <- read_csv(xwalk_filename) |>
    mutate(
      true_name = case_when(ipeds_dummy == TRUE ~ name,
                            ipeds_dummy == FALSE ~ true_name,
                            TRUE ~ NA_character_)
    ) |>
    select(og_name, true_name) |>
    drop_na(true_name) |>
    distinct()

  ipeds <- ipeds |>
    select(name, id) |>
    distinct()

  matched_xwalk <- xwalk |>
    left_join(ipeds, by = c(true_name = "name"))

  return(matched_xwalk)
}
