
# About -------------------------------------------------------------------

# Get termination rate tables for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.


# TODO --------------------------------------------------------------------

# Look for additional cleanup code that Reason has in other files and
# consolidate it here.

# Weird eco withdrawal rate at 4 yos. Presumably ok.

# deal with yos values. do we need to convert to single year?


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

FileName <- "Florida FRS inputs.xlsx"
fullpath  <- fs::path(dfrs, FileName)

# get and save data ----------------------------------------------------------

# excel_sheets finds the following 11 Withdrawal Rate tabs:
# [1] "Withdrawal Rate Regular Male"   "Withdrawal Rate Regular Female" "Withdrawal Rate Special Male"
# [4] "Withdrawal Rate Special Female" "Withdrawal Rate Eco"            "Withdrawal Rate Eso"
# [7] "Withdrawal Rate Judges"         "Withdrawal Rate Sen Man Male"   "Withdrawal Rate Sen Man Female"
# [10] "Withdrawal Rate Admin Female"   "Withdrawal Rate Admin Male"

# (It also finds a hidden tab called "Withdrawal Rates" that I do not use.)

# Eco, Eso, and Judges only have an all-genders table whereas the others have
# male and female versions

tabs <- excel_sheets(fullpath)
tabs |> str_subset("Withdrawal")
# read_excel(fullpath, sheet = "Withdrawal Rates")

wrtabs <- tabs |>
  str_subset("Withdrawal") |>
  setdiff("Withdrawal Rates")
wrtabs

f <- function(tab){
  print(tab)

  gender <- case_when(str_sub(tab, -4, -1) == "Male" ~ "male",
                      str_sub(tab, -6, -1) == "Female" ~ "female",
                      .default="all")

  class <- case_when(str_detect(tab, "Regular") ~ "regular",
                     str_detect(tab, "Special") ~ "special",
                     str_detect(tab, "Eco") ~ "eco",
                     str_detect(tab, "Eso") ~ "eso",
                     str_detect(tab, "Judges") ~ "judges",
                     str_detect(tab, "Sen Man") ~ "senior_management",
                     str_detect(tab, "Admin") ~ "admin",
                     .default = "ERROR")

  df1 <- read_excel(fullpath,
             sheet = tab,
             col_types = "text")

  df2 <- df1 |>
    mutate(system = "frs",
           class = class,
           gender = gender,
           yos = as.integer(yos)) |>
    pivot_longer(-c(system, class, gender, yos),
                 names_to = "age_group",
                 values_to = "term_rate")

  df2
}

f(wrtabs[1])

age_group_order <- c("under_25", "25_to_29", "30_to_34",
                     "35_to_44", "45_to_54", "over_55")

trates <- purrr::map(wrtabs, f) |>
  list_rbind() |>
  # percentage values read as character were not converted to decimal values
  mutate(term_rate=as.numeric(term_rate) / 100,
         # make age_group a factor so that it will sort in desired oder
         age_group = factor(age_group, levels = age_group_order)) |>
  select(system, class, gender, yos, age_group, term_rate) |>
  arrange(system, class, gender, yos, age_group)

skim(trates)
count(trates, class)
count(trates, gender)
count(trates, yos)
count(trates, age_group)

saveRDS(trates, path(dfrs, "termination_rates.rds"))


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

