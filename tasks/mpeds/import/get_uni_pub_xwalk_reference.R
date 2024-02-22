get_uni_pub_xwalk_reference <- function(id){
  id <- "1LwWIMylixuo8cAFK1xQSS12jybQhLZQF06J40ggp-4A"
  read_googlesheet(id, sheet = 1) |>
    janitor::clean_names() |>
    rename(uni_id = unit_id) |>
    pivot_longer(cols = contains("Newspaper"),
                 values_to = "newspaper_name") |>
    filter(name == "newspaper_1" | !is.na(newspaper_name)) |>
    select(-name) |>
    # Casting is necessary because many values incorrectly are interpreted
    # as <number>.0, or have the string value "NA".
    # So this chops off the ".0" at the end and converts those to true NAs,
    # and then reverts uni_id back to character
    mutate(uni_id = as.character(as.numeric(uni_id)))
}
