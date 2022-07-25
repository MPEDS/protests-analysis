library(targets)

fn_filenames <- list.files("tasks", full.names = TRUE,
                           recursive = TRUE)
invisible(lapply(fn_filenames, source))

tar_option_set(packages = "tidyverse")

list(
  tar_target(ipeds_demo, import_directory())
)
