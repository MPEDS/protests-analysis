
get_space_disruptions <- function() {

  integrated <- tar_read(integrated)

  integrated <- integrated |>
    st_drop_geometry() |>
    select(canonical_id, key, form, description, start_date, end_date) |>
    unnest(form)

}
