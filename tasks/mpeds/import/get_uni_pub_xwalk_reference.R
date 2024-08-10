get_uni_pub_xwalk_reference <- function(id){
  sheets <- read_googlesheet(id)
  bind_rows(sheets$US, sheets$Canada) |>
    janitor::clean_names() |>
    rename(uni_id = unit_id) |>
    pivot_longer(cols = contains("Newspaper"),
                 values_to = "newspaper_name") |>
    filter(name == "newspaper_1" | !is.na(newspaper_name)) |>
    select(-name)
}
