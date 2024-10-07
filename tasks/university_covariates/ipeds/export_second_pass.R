export_second_pass <- function(initial_xwalk, cleaned_events, ipeds_raw, glued_raw, canada_geo){
  initial_xwalk <- initial_xwalk |>
    select(
      canonical_id,
      uni_id = authoritative_id,
      authoritative_name,
      original_name,
      source = original_source
    ) |>
    mutate(
      source = str_replace_all(source, "-", "_"),
      original_name = ifelse(is.na(original_name), authoritative_name, original_name)
    )

  with_unis <- cleaned_events |>
    mutate(
      university = pmap(list(university, canonical_id), \(x, y) {
        x |> mutate(canonical_id = as.character(y))
      })
    ) |>
    nest_left_join(
      university,
      initial_xwalk,
      by = c("university_name" = "original_name",
             "canonical_id",
             "uni_name_source" = "source")
    )

  unmatched_corrections <- initial_xwalk |>
    filter(map_lgl(canonical_id, ~!(. %in% cleaned_events$canonical_id)),
           !is.na(uni_id),
           source != "publication")

  unmatched_database_entries <- cleaned_events |>
    filter(!str_detect(key, "Umbrella"),
           map_lgl(canonical_id, ~!(. %in% initial_xwalk$canonical_id))) |>
    select(key, description, publication, start_date, location, university) |>
    nest_select(university, uni_name_source, university_name) |>
    unnest(university) |>
    filter(uni_name_source != "publication") |>
    arrange(key) |>
    mutate(uni_id = "") |>
    select(key, uni_name_source, original_university_name = university_name, uni_id, everything())

  con <- connect_sheriff()
  articles <- tbl(con, "article_metadata") |>
    collect()
  publishing_universities <- articles |>
    select(publication) |>
    unique() |>
    arrange(publication)

  ipeds <- ipeds_raw |>
    group_by(UNITID) |>
    slice_max(order_by = year, n = 1) |>
    select(id = UNITID, name = INSTNM, address = ADDR,
           city = CITY, state = STABBR)

  glued <- glued_raw |>
    filter(country == "canada") |>
    group_by(iau_id1) |>
    slice_max(order_by = year, n = 1) |>
    select(id = iau_id1, uni_name = eng_name, foundedyr, coordinates) |>
    separate(coordinates, sep = ", ", into = c("lat", "lon")) |>
    st_as_sf(coords = c("lon", "lat"), na.fail = FALSE) |>
    st_set_crs(st_crs(canada_geo)) |>
    st_join(canada_geo) |>
    select(-geoid) |>
    st_drop_geometry()


  sheet <- list(
    "Unmatched Corrections" = unmatched_corrections,
    "Unmatched Database Entries" = unmatched_database_entries,
    "Publishing universities" = publishing_universities,
    IPEDS = ipeds,
    GLUED = glued
  )

  second_pass_filename <- "tasks/university_covariates/hand/second_pass.xlsx"
  writexl::write_xlsx(sheet, second_pass_filename)
  return(second_pass_filename)
}
