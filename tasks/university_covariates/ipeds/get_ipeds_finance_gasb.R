# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
get_ipeds_finance_gasb <- function(){
  years <- 2012:2018
  finance_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      # 2018 -> "1718", as in the 2017-18 academic year. For the filename naming format
      year_format <- paste0(
        str_sub(year - 1, 3,4),
        str_sub(year, 3,4)
      )
      url <- paste0(base_url, "F", year_format, "_F1A.zip")
      filename <- tempfile()
      download.file(url, filename, method = "curl", quiet = FALSE)
      unzipped_filename <- unzip(filename, exdir = tempdir())
      unzipped_filename <- ifelse(any(str_detect(unzipped_filename, "_rv")),
                                      str_subset(unzipped_filename, "_rv"),
                                      unzipped_filename)
      # Total revenues and investment return is the sum of the following amounts:
      # tuition and fees
      # government appropriations, grants and contracts
      # private gifts, grants, and contracts
      # contributions from affiliated entities
      # investment return (income, gains, and losses)
      # sales and services of educational activities and auxiliary enterprises
      # hospital revenue
      # independent operations revenue
      # and other revenue.
      finance <- read_csv(unzipped_filename, show_col_types = FALSE) |>
        mutate(
          # danger !
          across(where(is.numeric), ~if_else(is.na(.), 0, .)),
          uni_id = as.character(UNITID),
          government_revenue =
            # Appropriations (federal, state, local)
            F1B10 + F1B11 + F1B22 +
            # Operating grants and contracts
            F1B02 + F1B03 + F1B04A +
            # Nonoperating grants
            F1B13 + F1B14 + F1B15,
          sales_services_revenue = F1B26 + F1B05,
          endowment_assets = log(as.numeric(F1H01)),
          year = year
        ) |>
        select(
          uni_id,
          year,
          endowment_assets,
          revenue_total = F1D01,
          expenses_total = F1D02,

          # Interesting variables marked with #
          government_revenue,
          sales_services_revenue,
          #
          tuition_revenue = F1B01,
          #
          private_revenue = F1B04B,
          affiliated_contributions_revenue = F1B16,
          # don't want to piss off donors if investment is highly valued?
          investment_revenue = F1B17,
          hospital_revenue = F1B06,
          independent_operations_revenue = F1B07,
          other_revenue = F1B08,

          instruction_expenses = F1C011,
          research_expenses = F1C021,
          public_service_expenses = F1C031,
          academic_support_expenses = F1C061,
          student_service_expenses = F1C062,
          institutional_support_expenses = F1C071,
          auxiliary_enterprises_expenses = F1C111,
          net_grant_aid_expenses = F1C101,
          hospital_expenses_expenses = F1C121,
          independent_operations_expenses = F1C131,
          other_expenses = F1C141
        ) |>
        mutate(across(contains("_revenue"), ~100*round(./revenue_total, 2)),
               across(contains("_expenses"), ~100*round(./expenses_total, 2)),
               across(where(is.numeric), ~ifelse(is.infinite(.), 0, .)))

      return(finance)
  })
  return(finance_aggregated)
}
