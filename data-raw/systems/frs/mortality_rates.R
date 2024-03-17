
# frs: Florida Retirement System

# This program gets mortality tables for FRS, from an
# Excel workbook (pub-2010-headcount-mort-rates.xlsx) that Reason created.


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")


# get data ----------------------------------------------------------------

mort <- pendata::pub2010hc_mortality_rates |>
  mutate(system="frs") |>
  relocate(system)

glimpse(mort)
ht(mort)

saveRDS(mort, path(dfrs, "mortality_rates.rds")) # one of the files we will save

# later, we will gather up all of the files for a system and put them into
# a big list for the system e.g., frs$mort_rates, frs$salary_scale
# that can be loaded into the model

# pivot_wider(names_from = gender, values_from = rate) |>
# mutate(all=(male + female) / 2) |>
# pivot_longer(cols=c(male, female, all),
#              names_to = "gender", values_to = "rate") |>
# select(employee_type, beneficiary_type, gender, age, rate)



# readRDS(path(ddir, "mort_rates.rds"))

# note that Truong also does the following in the benefit model
# Create this mort table for regular employees who are either teachers or general employees
#   base_regular_mort_table <- (base_general_mort_table + base_teacher_mort_table)/2
# in other words, he uses the average for teachers and general, but not for safety??

# this is addressed in the table above by creating "all" rows for the gender
# column, which is the average for everything

