# Please generate a spreadsheet for any protests that are coded with
# Police Actions: Monitor/Present and also have any Police Action field
# coded other than these three: Cooperate, Participate, Breaking the Rules

get_police_activities_monitor <- function() {

  tar_load(integrated)

  police_responses <- integrated |>
    st_drop_geometry() |>
    filter(map_lgl(police_activities, ~"Monitor/Present" %in% .),
           map_lgl(police_activities, \(activities){
             length(activities[!(activities %in% c("Cooperate/Coordinate", '"Breaking the Rules"',
                                                   "Participate"))]) > 1
           })) |>
    select(canonical_id, key, description, police_activities) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))

  other_monitor <- integrated |>
    st_drop_geometry() |>
    filter(map_lgl(police_activities, ~"Monitor/Present" %in% .),
           !(key %in% police_responses$key)) |>
    select(canonical_id, key, description, police_activities) |>
    mutate(across(where(is.list), ~map_chr(., ~paste(., collapse = ", "))))


  writexl::write_xlsx(lst(police_responses, other_monitor),
                      "docs/data-cleaning-requests/low-level-data-cleaning/police_responses_monitor.xlsx")

}

