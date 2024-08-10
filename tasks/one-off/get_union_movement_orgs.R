
get_union_movement_orgs <- function() {
  integrated <- tar_read(integrated)

  orgs <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key, movement_organizations_text) |>
    unnest(cols = movement_organizations_text) |>
    filter(str_detect(tolower(movement_organizations_text), "union"))
}
