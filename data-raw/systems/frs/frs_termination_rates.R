
# About -------------------------------------------------------------------

# Get termination rate tables for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.


# TODO --------------------------------------------------------------------

# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

FileName <- "Florida FRS inputs.xlsx"

# get data ----------------------------------------------------------------
fpath  <- fs::path(dfrs, FileName)

df1 <- read_excel(fpath,
                  sheet = 1,
                  range = cellranger::cell_cols(1:length(colnames)),
                  col_names = colnames,
                  col_types = "text")

regular_term_rate_male_table_ <- read_excel(fpath, sheet = "Withdrawal Rate Regular Male")

# Truong's code, commented-out ----
# Termination rate tables

# regular_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Regular Male")
# regular_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Regular Female")
#
# special_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Special Male")
# special_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Special Female")
#
# admin_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Admin Male")
# admin_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Admin Female")
#
# eco_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Eco")
# eco_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Eco")
#
# eso_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Eso")
# eso_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Eso")
#
# judges_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Judges")
# judges_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Judges")
#
# senior_management_term_rate_male_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Sen Man Male")
# senior_management_term_rate_female_table_ <- read_excel(FileName, sheet = "Withdrawal Rate Sen Man Female")

