get_covariates <- function() {
  tribble(
    ~category, ~name, ~formatted,
    "University", "is_uni_public", "Public/Private status (1 = Public)",
    "University", "nonwhite_staff_pct", "Percent of nonwhite instructors",
    "University", "pct_non_tenure", "Percent of non-tenured instructional staff",
    "University", "pct_women_instructors", "Percent of instructional staff that are women",
    "University", "instruction_expenses", "Percent of expenses spent on instruction",
    "University", "investment_revenue", "Percent of revenue coming from investments",
    "University", "uni_total_pop", "Total enrollment at university (thousands)",
    "University", "pell", "Percent of Pell grant recipients",
    "University", "endowment_assets", "Log-10 of endowment assets",
    "County", "white_prop", "White percent in county of university",
    "County", "mhi", "Median household income (thousands)",
    "County", "rent_burden", "Percent of households spending more than 30% of income on rent",
    "County", "republican_vote_prop", "Percent in county voting Republican in 2016 presidential election"
  )
}
