get_hotbeds <- function(xwalk_sheet_id, hotbeds_sheet_id){
  xwalk <- read_googlesheet(xwalk_sheet_id, "Sheet to clean") |>
    clean_names() |>
    mutate(authoritative_id = ifelse(is.na(authoritative_id), merged_into_authoritative_id, authoritative_id)) |>
    select(id, authoritative_id) |>
    drop_na(authoritative_id)

  hotbeds <- read_googlesheet(hotbeds_sheet_id, "COLLACT.DAT") |>
    select(id, fspart, fsappl, pastact, sdschap, earlysds) |>
    mutate(in_hotbeds = TRUE,
           across(c(fsappl, pastact, sdschap, earlysds), as.logical))

  hotbeds |>
    distinct() |> # ??? Duplicated rows in original data
    filter(id != 154) |> # ??? Multiple universities have id 154 in original data
    left_join(xwalk, by = "id") |>
    drop_na(authoritative_id) |> # Some colleges closed, so no corresponding authoritative ID now
    group_by(uni_id = authoritative_id) |> # Some colleges were merged since the original data
    summarize(fspart = sum(fspart, na.rm=T),
              across(c(fsappl, pastact, sdschap, earlysds, in_hotbeds), any)
              )

}
