combine_ipeds <- function(ipeds_list){
  ipeds <- ipeds_list |>
    reduce(full_join, by = c("uni_id", "year"))

  ipeds_keys <- expand_grid(
    year = 2012:2018,
    uni_id = unique(ipeds$uni_id)
  )

  # Lots of universities are missing data between 2012 and 2018 --
  # Just adding in those rows as blank entries for now

  ipeds |>
    full_join(ipeds_keys, by = join_by(uni_id, year))
}
