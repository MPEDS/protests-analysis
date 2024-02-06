tar_cue_if <- function(flag){
  tar_cue(mode = ifelse(
    tolower(Sys.getenv(flag)) %in% c('', 'false'),
    'never',
    'always'
  ))
}
