source("renv/activate.R")

options(tigris_use_cache = TRUE,
        timeout = 1000 # for large download.file requests on slow internet speeds
        )

# convenience functions meant for quick interactive debugging
# they should NEVER be used in a target

#' Loads in a target
#' tl = "tar_load"
tl <- targets::tar_load

#' Counts unique items in a vector
#' Dead simple but often annoying to type repeatedly
#' nu = number of unique items
nu <- function(vec){
  length(unique(vec))
}

if(interactive()){
  # hate typing this every time i start a session
  # notably not loaded by the pipeline runs
  library(stats) # to avoid conflict with dplyr filter
  library(tidyverse)
  library(targets)
  library(RMariaDB)
  library(ssh)
  library(sf)
}

