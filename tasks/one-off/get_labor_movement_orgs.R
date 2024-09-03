


get_unions <- function() {

  integrated <- tar_read(integrated)

  labor_protests <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, issue, movement_organizations_text) |>
    filter(issue == "Labor and work")
    # unnest(movement_organizations_text)
    # unnest(c(issue, movement_organizations_text)) |>
    # mutate(y = fun(x, y, z)) |> unnest(y)

}
