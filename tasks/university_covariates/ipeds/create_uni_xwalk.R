create_uni_xwalk <- function(initial_xwalk, second_xwalk){
  initial_xwalk <- initial_xwalk |>
    select(canonical_id, original_name, source = original_source, uni_id = authoritative_id,
           authoritative_name)
  corrections <- second_xwalk$`Unmatched Corrections` |>
    select(canonical_id, original_name, source, uni_id, authoritative_name)
  additions <- second_xwalk$`Unmatched Database Entries` |>
    select(canonical_id, original_name = original_university_name,
           source = uni_name_source, uni_id)

  xwalk <- list(initial_xwalk, corrections, additions) |>
    map(~mutate(., canonical_id = as.character(canonical_id))) |>
    bind_rows() |>
    # Some duplicates in crosswalks emerge because coders corrected
    # canonical events with different keys as the same
    distinct() |>
    mutate(uni_id = str_remove(uni_id, "\\.0"))
  return(xwalk)
}
