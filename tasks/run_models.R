run_models <- function(integrated){


  linear_reg() |>
    set_engine("lm") |>
    fit()

}
