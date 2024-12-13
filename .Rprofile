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

#' Loads the targets referenced by function arguments
tar_load_args <- function(fun){
  tar_load(names(formals(fun)), envir = parent.frame(n = 2))
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
  library(nplyr)
  library(googledrive)
  library(readxl)
  library(janitor)
  library(survival)


  # Loads some utility functions that are a pain to manually load in interactive
  # IMO doesn't break reproducibility because these same functions are
  # sourced automatically in pipeline runs
  utils <- list.files("tasks/utils", full.names=T)
  walk(utils, \(util){source(util, local = .GlobalEnv)})

}

