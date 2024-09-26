


get_labor_movement_orgs <- function() {

  integrated <- tar_read(integrated)
  integrated <- integrated |>
    st_drop_geometry() |>
    mutate(country = if_else(str_extract(geoid, "us|canada") == "us", "US", "Canada") |>
             fct_relevel("US", "Canada")
    )

  labor_protests <- integrated |>
    st_drop_geometry() |>
    filter(map_lgl(issue, ~"Labor and work" %in% .)) |>
    select(canonical_id, key, country, description, issue, movement_organizations_text)

  labor_issue <- labor_protests |>
    filter(!is.na(movement_organizations_text)) |>
    unnest(movement_organizations_text) |>
    arrange(country)

  movement_orgs_text <- integrated |>
    filter(map_lgl(movement_organizations_text, ~any(str_detect(tolower(.), "union")))) |>
    select(canonical_id, key, country, description, issue, movement_organizations_text) |>
    filter(!is.na(movement_organizations_text)) |>
    unnest(movement_organizations_text) |>
    filter(str_detect(tolower(movement_organizations_text),"union")) |>
    arrange(country)

  labor_movement_orgs <- labor_issue |>
    bind_rows(movement_orgs_text) |>
    arrange(movement_organizations_text)

  labor_movement_orgs_us <- labor_movement_orgs |>
    filter(country=="US")

  labor_movement_orgs_ca <- labor_movement_orgs |>
    filter(country=="Canada")

  writexl::write_xlsx(lst(labor_movement_orgs_us, labor_movement_orgs_ca, labor_movement_orgs),
                      "docs/data-cleaning-requests/labor_movement_orgs.xlsx")

  return(labor_movement_orgs)
}
