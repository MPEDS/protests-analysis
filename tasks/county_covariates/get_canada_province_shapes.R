#' Downloads provinces and territories from 
get_canada_province_shapes <- function(){
  download_location <- tempfile()
  download.file(
    "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lpr_000b21a_e.zip",
    download_location
  )
  
  unzip(download_location,
        exdir = paste0(tempdir(), "/canada-provinces"))
  
  canada_province_shapes <- read_sf(paste0(tempdir(), "/canada-provinces")) |> 
    rmapshaper::ms_simplify()
  
}