
get_police_composites <- function () {

  tar_load(integrated)

  is_in_list <- function(col, values){
    map_lgl(col, ~any(values %in% .))
  }

  police_composites <- integrated |>
    st_drop_geometry() |>
    mutate(
      is_passive_policing = is_in_list(
        police_activities,
        c("Monitor/Present", "Cooperate/Coordinate", "Instruct/Warn")),

      is_repressive_policing = is_in_list(
        police_activities,
        c("Constrain", "Remove Individual Protesters", "End Protest",
          "Force: Vague/Body", "Force: Weapon", "Force: 2+ Weapon Types",
          "Detain", "Arrest or Attempted", "Arrest- Large Scale", "Formal Accusation")),

      is_participatory_policing = is_in_list(
        police_activities, "Participate"),

      # for calculations only -- REMOVE from dataframe
      is_university_police = is_in_list(
        type_of_police,
        c("Univ police", "Univ police - assumed")),
      is_government_police = is_in_list(
        type_of_police,
        c("Govt police", "Govt police - assumed", "\"Riot police\"")),
      is_other_police = is_in_list(
        type_of_police,
        c("Private Security", "Secret Service")),
      is_NA_unclear = is_in_list(
        type_of_police,
        "NA/Unclear"),


      is_university_police_only = is_university_police & !is_government_police &
        !is_other_police,
      is_government_and_riot_police_only = !is_university_police & is_government_police &
        !is_other_police,
      is_both_university_and_government_police = is_university_police & is_government_police,
      is_no_police_reported = !is_university_police & !is_government_police &
                              !is_other_police & !is_NA_unclear)

      is_extreme_policing = is_in_list(
        police_activities,
        c("Force: 2+ Weapon Types", "Arrest- Large Scale")) |
        is_in_list(type_of_police, "\"Riot police\"") |
        is_in_list(police_presence_and_size, c("Heavily Policed", "Motorized Presence")) |>

      select(-is_university_police,-is_government_police,-is_other_police,-is_NA_unclear)

    any_police <- police_composites |>
      filter(!is_no_police_reported) |>
      nrow()

    police_counts <- police_composites |>
      select(starts_with("is_")) |>
      pivot_longer(
        cols = starts_with("is_"),
        names_to = "type_of_police"
      ) |>
      group_by(type_of_police) |>
      summarize(n = sum(value)) |>
      mutate(percentage_all_protests = n / length(unique(integrated$canonical_id)),
             percentage_protests_with_any_police_involvement = n / any_police)


}
