

# Tables needed
  # salary_headcount_table
  # term_rate_age
  # mort_table
  # entrant_profile_table
  # mort_retire_table
  # normal_retire_rate_table
  # early_retire_rate_table
  # separation_rate_table
  # salary_growth_table


source(here::here("data-raw", "libraries.r"))
# search()
sessioninfo::session_info()


ddata <- here::here("data")
draw <- here::here("data-raw")
dtxtrs <- fs::path(draw, "txtrs")

fname <- "TxTRS_BM_Inputs.xlsx"
fpath <- fs::path(dtxtrs, fname)

# base mortality table -  use the pub-2010 amount table from SOA ----

base_mort_table <- pub2010amount_mortality_rates |>
  select(age, beneficiary_type, gender, rate)
glimpse(base_mort_table) # stacked version

# age beneficiary_type gender rate

# mortality improvement table ----
male_mp_table_ <- read_excel('Inputs/mp-2021-rates.xlsx', sheet = "Male")
female_mp_table_ <- read_excel('Inputs/mp-2021-rates.xlsx', sheet = "Female")


# tx trs tables Reason used ----
fname <- "TxTRS_BM_Inputs.xlsx"
fpath <- fs::path(dtxtrs, fname)

survival_rates <- read_excel(fpath, sheet = "Mortality Rates")

MaleMP <- read_excel(fpath, sheet = "MP-2018_Male")
FemaleMP <- read_excel(fpath, sheet = "MP-2018_Female")

SalaryGrowthYOS <- read_excel(fpath, sheet = "Salary Growth YOS")
SalaryMatrix <- read_excel(fpath, sheet = "Salary Matrix")
HeadCountMatrix <- read_excel(fpath, sheet = "Head Count Matrix")
SalaryEntry <- read_excel(fpath, sheet = "Entrant Profile")

TerminationRateAfter10 <- read_excel(fpath, sheet = 'Termination Rates after 10')
TerminationRateBefore10 <- read_excel(fpath, sheet = 'Termination Rates before 10')
RetirementRates <- read_excel(fpath, sheet = 'Retirement Rates')

ReducedGFT <- read_excel(fpath, sheet = "Reduced GFT")
ReducedOthers <- read_excel(fpath, sheet = "Reduced Others")

RetireeDistribution <- read_excel(fpath, sheet = "Retiree Distribution")

funding_data <- read_excel(fpath, sheet = "Funding Data")
return_scenarios <- read_excel(fpath, sheet = "Return Scenarios")


# DON'T RUN -- Reason code from TxTRS_model_inputs.R ----
#7. Import key data tables
FileName <- 'TxTRS_BM_Inputs.xlsx'

SurvivalRates <- read_excel(FileName, sheet = 'Mortality Rates')
MaleMP <- read_excel(FileName, sheet = 'MP-2018_Male')
FemaleMP <- read_excel(FileName, sheet = 'MP-2018_Female')

SurvivalRates_ <- read_excel("Inputs/pub-2010-amount-mort-rates.xlsx", sheet = "PubT-2010(B)")
male_mp_table_ <- read_excel('Inputs/mp-2021-rates.xlsx', sheet = "Male")
female_mp_table_ <- read_excel('Inputs/mp-2021-rates.xlsx', sheet = "Female")

SalaryGrowthYOS <- read_excel(FileName, sheet = "Salary Growth YOS")
SalaryMatrix <- read_excel(FileName, sheet = "Salary Matrix")
HeadCountMatrix <- read_excel(FileName, sheet = "Head Count Matrix")
SalaryEntry <- read_excel(FileName, sheet = "Entrant Profile")

TerminationRateAfter10 <- read_excel(FileName, sheet = 'Termination Rates after 10')
TerminationRateBefore10 <- read_excel(FileName, sheet = 'Termination Rates before 10')
RetirementRates <- read_excel(FileName, sheet = 'Retirement Rates')

ReducedGFT <- read_excel(FileName, sheet = "Reduced GFT")
ReducedOthers <- read_excel(FileName, sheet = "Reduced Others")

RetireeDistribution <- read_excel(FileName, sheet = "Retiree Distribution")

funding_data <- read_excel(FileName, sheet = "Funding Data")
return_scenarios <- read_excel(FileName, sheet = "Return Scenarios")
