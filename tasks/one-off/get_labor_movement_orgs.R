


get_labor_movement_orgs <- function() {

  integrated <- tar_read(integrated)

  labor_protests <- integrated |>
    st_drop_geometry() |>
    filter(map_lgl(issue, ~"Labor and work" %in% .)) |>
    select(canonical_id, key, issue, movement_organizations_text)

  labor_movement_orgs <- labor_protests |>
    filter(!is.na(movement_organizations_text)) |>
    unnest(movement_organizations_text)

  writexl::write_xlsx(labor_movement_orgs,
                      "docs/data-cleaning-requests/labor_movement_orgs.xlsx")

  return(labor_movement_orgs)
}
