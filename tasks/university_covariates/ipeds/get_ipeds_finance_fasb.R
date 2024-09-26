# See https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true
# for possible datasets and URLs
# For data: https://nces.ed.gov/ipeds/datacenter/data/F1718_F2.zip
# For dictionary: https://nces.ed.gov/ipeds/datacenter/data/F1718_F2_Dict.zip
get_ipeds_finance_fasb <- function(){
  years <- 2012:2018
  finance_aggregated <- map_dfr(
    years, function(year){
      base_url <- "https://nces.ed.gov/ipeds/datacenter/data/"
      # 2018 -> "1718", as in the 2017-18 academic year. For the filename naming format
      year_format <- paste0(
        str_sub(year - 1, 3,4),
        str_sub(year, 3,4)
      )
      url <- paste0(base_url, "F", year_format, "_F2.zip")
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
            F2D02 + F2D03 + F2D04 +
            # Grants and contracts
            F2D05 + F2D06 + F2D07,
          sales_services_revenue = F2D11 + F2D12,
          endowment_assets = log(as.numeric(F2H01)),
          year = year
        ) |>
        select(
          uni_id,
          year,
          endowment_assets,
          revenue_total = F2D16,
          expenses_total = F2E131,

          # Interesting variables marked with #
          government_revenue,
          sales_services_revenue,
          #
          tuition_revenue = F2D01,
          #
          private_revenue = F2D08,
          affiliated_contributions_revenue = F2D09,
          # don't want to piss off donors if investment is highly valued?
          investment_revenue = F2D10,
          hospital_revenue = F2D13,
          independent_operations_revenue = F2D14,
          other_revenue = F2D15,

          instruction_expenses = F2E011,
          research_expenses = F2E021,
          public_service_expenses = F2E031,
          academic_support_expenses = F2E041,
          student_service_expenses = F2E051,
          institutional_support_expenses = F2E061,
          auxiliary_enterprises_expenses = F2E071,
          net_grant_aid_expenses = F2E081,
          hospital_expenses = F2E091,
          independent_operations_expenses = F2E101,
          other_expenses = F2E121
        ) |>
        mutate(across(contains("_revenue"), ~100*round(./revenue_total, 2)),
               across(contains("_expenses"), ~100*round(./expenses_total, 2)),
               across(where(is.numeric), ~ifelse(is.infinite(.), 0, .)))

      return(finance)
  })
  return(finance_aggregated)
}
