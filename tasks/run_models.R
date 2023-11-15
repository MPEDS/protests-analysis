run_models <- function(integrated){

  linear_reg() |>
    set_engine("lm") |>
    fit()

  dates <- seq.Date(min(integrated$start_date, na.rm = TRUE),
                    max(integrated$start_date, na.rm = TRUE),
                    by = 1)
  uni_history <- integrated |>
    select(uni)

  # event_history
  # Surv() ~

}
