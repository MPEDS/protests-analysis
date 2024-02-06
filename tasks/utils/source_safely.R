# Sources a file while ensuring:
# 1) The file does nothing but assign functions to variables
# 2) Functions do not conflict with objects in the namespace `source_safely()`
#     is called from
source_safely <- function(filename){
  given_exprs <- readr::read_file(filename) |>
    rlang::parse_exprs()

  error_env <- rlang::current_env()
  namespace_env <- parent.env(error_env)

  # Check the file for the above cases
  check_requirements <- function(given_expr){
    # first three tokens should always be "<-",
    # unconflicting function name,
    # and the function() declaration
    is_arrow <- as.character(given_expr[[1]]) == "<-"
    if(!is_arrow){
      rlang::abort(
        c(
          "Files should only assign functions to variables, not perform evaluations.",
          "*" = paste0("The file \"", filename, "\" did not begin by declaring a function.")
        ),
        call = error_env
      )
    }

    function_name <- as.character(given_expr[[2]])
    namespace_env_names <- names(namespace_env) |>
      stringr::str_subset("^source_safely$", negate = TRUE)
    is_unconflicting <- !(function_name %in% namespace_env_names)
    if(!is_unconflicting){
      rlang::abort(
        c(paste("Duplicate variable name detected:", function_name),
          "*" = "Each expression in a file should declare an unconflicting variable.",
          "*" = stringr::str_wrap(paste0(
            "The file \"", filename, "\" declared `", function_name,
            "`, which already exists in the parent environment of `source_safely.`"
            ))
          ),
        call = error_env)
    }

    assignment_value <- as.character(given_expr[[3]][[1]])
    is_function <- assignment_value == "function"
    if(!is_function){
      abort(c(
        "Non-function value detected.",
        "*" = "Each expression in a file should be a function assignment.",
        "*" = paste0("The file \"", filename, "\" had `", assignment_value, "` instead."),
        call = error_env
      ))
    }
  }
  purrr::walk(given_exprs, check_requirements)

  # If errors pass just source it
  source(filename)
}
