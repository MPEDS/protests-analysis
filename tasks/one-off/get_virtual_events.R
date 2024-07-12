# pulling all virtual events so that coders can get their locations

get_virtual_events <- function() {

  integrated <- tar_read(integrated)

  virtual_events <- integrated |>
    st_drop_geometry() |>
    filter(str_detect(tolower(key), "virtual")) |>
    unnest(cols = c(university), names_repair = "minimal")
    select(canonical_id,key,location,description, uni_name)



  writexl::write_xlsx(virtual_events,
                      "docs/data_cleaning_requests/virtual_events.xlsx")
}
