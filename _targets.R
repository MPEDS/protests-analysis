library(targets)


fn_filenames <- list.files("tasks", full.names = TRUE,
                           pattern = ".R",
                           recursive = TRUE)
invisible(lapply(fn_filenames, source))

tar_option_set(packages = c("tidyverse", "ssh", "httr"))

list(
  tar_target(coder_table, get_coder_table(),
            # uncomment cue = ... to force an update, since technically
            # targets has no knowledge of changes on the server
            # and won't update the data on its own
            # cue = tar_cue(mode = "always"))
            # tar_target(ipeds_demo, import_directory())
     ),
  tar_target(uni_pub_xwalk_file, format = "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  tar_target(coder_table_wide, process_coder_table(coder_table, uni_pub_xwalk_file)),
  tar_target(geocoded_locations, get_protest_coords(coder_table_wide))
)

