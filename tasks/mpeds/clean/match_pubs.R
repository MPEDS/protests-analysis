match_pubs <- function(filename, uni_pub_xwalk_reference){
  pubs <- tar_read(canonical_events) |>
    select(publication) |>
    mutate(in_ipeds = TRUE,
           publication = str_replace(publication, " - ", "-") |>
             str_replace("-", " - ")) |> # standardizing dashes, trust me
    distinct()
  uni_pub_xwalk_reference |>
    mutate(university_college = str_replace(university_college, " - ", "-") |>
             str_replace("-", " - "), # standardizing dashes, trust me
           publication = paste0(newspaper_name, ": ", university_college)) |>
    select(uni_id, publication) |>
    full_join(pubs, by = join_by(publication)) |>
    filter(in_ipeds, is.na(uni_id)) |>
    select(-uni_id, -in_ipeds) |>
    separate(publication, sep = ":", into = c("university", "publication")) |>
    mutate(across(where(is.character), ~str_trim(.) |> str_replace(" - ", "-"))) |>
    write_csv("docs/data-cleaning-requests/pub_mismatches.csv")
}
