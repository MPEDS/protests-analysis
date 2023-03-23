#' URL is hard-coded here again because it doesn't provide ETag or Last-Modified-By
#' headers
#' See dataset UI at https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410038001&pickMembers%5B0%5D=2.5&pickMembers%5B1%5D=3.1&pickMembers%5B2%5D=4.1&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=2012&cubeTimeFrame.endMonth=12&cubeTimeFrame.endYear=2018&referencePeriods=20120101%2C20181201
get_canada_unemployment <- function(canada_cma_shapes){
  keys <- select(canada_cma_shapes, canada_geouid) |>
    st_drop_geometry()
  url <- "https://www150.statcan.gc.ca/t1/tbl1/en/dtl!downloadDbLoadingData-nonTraduit.action?pid=1410038001&latestN=0&startDate=20120101&endDate=20181201&csvLocale=en&selectedMembers=%5B%5B%5D%2C%5B5%5D%2C%5B1%5D%2C%5B1%5D%5D&checkedLevels=0D1%2C0D2%2C0D3%2C0D4"
  read_csv(url) |>
    mutate(canada_geouid = str_sub(DGUID, 10, -1)) |>
    select(canada_unemp = VALUE, canada_geouid) |>
    right_join(keys, by =  "canada_geouid")
}
