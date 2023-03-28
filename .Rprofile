source("renv/activate.R")

options(tigris_use_cache = TRUE,
        timeout = 1000 # for large download.file requests on slow internet speeds
        )

# convenience functions meant for quick interactive debugging
# they should NEVER be used in a target

#' Loads in a target
#' tr = "target read", as in tar_read, which it basically is the same as
tr <- function(name, branches = NULL, meta = tar_meta(store = store),
               store = targets::tar_config_get("store")){
  name <- tar_deparse_language(substitute(name))
  object <- tar_read_raw(name = name, branches = branches, meta = meta,
               store = store)
  assign(name, object, envir = .GlobalEnv)
}

#' Counts unique items in a vector
#' Dead simple but often annoying to type repeatedly
#' nu = number of unique items
nu <- function(vec){
  length(unique(vec))
}
