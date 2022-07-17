library(targets)

fn_filenames <- list.files("src", full.names = TRUE,
                           recursive = TRUE)
invisible(lapply(fn_filenames, source))

tar_option_set(packages = "tidyverse")

list(
  tar_target(ipeds_demo, get_ipeds())
)
