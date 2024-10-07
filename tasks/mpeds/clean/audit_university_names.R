audit_university_names <- function(integrated, ipeds, glued, uni_xwalk){
  source("tasks/mpeds/import/connect_sheriff.R")
  con <- connect_sheriff()

  all_mismatches <- integrated |>
    select(key, university) |>
    unnest(cols = c(university)) |>
    filter(is.na(uni_name)) |>
    st_drop_geometry() |>
    select(canonical_id, key, university_name,
           uni_name_source, uni_id, corrected_name = uni_name)

  # Scenario: Wrong ID exists in university names spreadsheet
  wrong_ids <- all_mismatches |>
    filter(!is.na(uni_id)) |>
    select(-corrected_name, -uni_id, -key)

  # Scenario: IPEDS and GLUED have the IDs, but the match fails
  # because they don't have the full set of years
  mismatch_ids <- all_mismatches |>
    select(uni_name_source, canonical_id, university_name, uni_id) |>
    drop_na(uni_id)
  uni_covs <- bind_rows(ipeds, glued) |>
    select(uni_id) |>
    distinct() |>
    mutate(in_uni_covs = TRUE)
  year_mismatches <- mismatch_ids |>
    left_join(uni_covs, by = join_by(uni_id)) |>
    filter(is.na(in_uni_covs)) |>
    mutate(is_year_mismatch = TRUE) |>
    select(-in_uni_covs, -uni_id)

  # Scenario: Protests were added after the uni names spreadsheet was created
  # on May 10, 2023
  coder_event_creator <- tbl(con, "coder_event_creator") |> collect()
  link <- tbl(con, "canonical_event_link") |>
    select(cec_id, canonical_id) |>
    collect()
  outdated_mismatches <- coder_event_creator |>
    left_join(link, by = c("id" = "cec_id")) |>
    filter(variable %in% c(
      "participating-universities-text", "university-names-text"
      ),
      timestamp > "2023-05-10"
      ) |>
    mutate(variable = ifelse(variable == "university-names-text",
                             "other univ where protest occurs",
                             variable) |>
             str_replace_all("-", "_"),
           text = text |>
             str_remove_all(",") |>
             str_trim(),
           canonical_id = as.character(canonical_id),
           is_outdated = TRUE) |>
    select(uni_name_source = variable, canonical_id, university_name = text, is_outdated) |>
    right_join(all_mismatches, by = join_by(
      canonical_id, uni_name_source, university_name),
      relationship = "many-to-many") |>
    filter(is_outdated) |>
    select(-key, -uni_id, -corrected_name)

  # Was a publication that didn't make it into uni_xwalk
  pub_mismatch <- all_mismatches |>
    select(canonical_id, university_name, uni_name_source) |>
    filter(uni_name_source == "publication") |>
    left_join(mutate(uni_xwalk, in_xwalk = TRUE), by = join_by(
      canonical_id,
      university_name == original_name,
      uni_name_source == source)) |>
    filter(is.na(in_xwalk)) |>
    mutate(is_pub_mismatch = TRUE) |>
    select(-uni_id, -in_xwalk)

  # Scenario: Is a Cégep
  cegep_mismatches <- all_mismatches |>
    filter(str_detect(str_to_lower(university_name), "cégep|cegep")) |>
    select(-uni_id, -key, -corrected_name) |>
    mutate(is_cegep = TRUE)

  # Tabulating all the different things so far
  combined_mismatches <- list(
    all_mismatches,
    wrong_ids,
    cegep_mismatches,
    outdated_mismatches,
    year_mismatches,
    pub_mismatch
  ) |>
    reduce(left_join, by = join_by(
      canonical_id, university_name, uni_name_source
      )) |>
    mutate(is_none = is.na(is_pub_mismatch) &
             is.na(is_year_mismatch) &
             is.na(is_cegep) &
             is.na(is_outdated)) |>
    pivot_longer(cols = starts_with("is_")) |>
    filter(value)

  # see if any are both (~3 are, which is fine)
  duplicate_mismatch <- combined_mismatches |>
    group_by(canonical_id, key, university_name, uni_name_source) |>
    filter(n() > 1)
  combined_mismatches |>
    group_by(name) |>
    count()
}
check_cec <- function(canonical_id){
  ids <- link |>
    filter(canonical_id == {{canonical_id}}) |>
    pull(cec_id)
  cec |>
    filter(id %in% ids, str_detect(variable, "publication|university-names|participating")) |>
    select(variable, text, timestamp)
}
