#' @param num
#' @example 1928 -> 1,928
format_num <- function(num){
  case_when(
    abs(num) > 1e5 | abs(num) < 1e-4 ~ formatC(num, digits = 3, big.mark = ","),
    TRUE ~ prettyNum(round(num, digits = 3), big.mark = ",")
  )
}
