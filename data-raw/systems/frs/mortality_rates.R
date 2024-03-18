
# frs: Florida Retirement System

# This program gets mortality tables for FRS, from an
# Excel workbook (pub-2010-headcount-mort-rates.xlsx) that Reason created.


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")


# get data ----------------------------------------------------------------

mort1 <- pendata::pub2010hc_mortality_rates |>
  mutate(system="frs") |>
  relocate(system)

glimpse(mort1)
ht(mort1)
count(mort1, employee_type)
count(mort1, beneficiary_type)
count(mort1, gender)
count(mort1, age) |> ht()


# base mortality table ------------------------------------

# base mortality table: per Reason:
#   regular: average of SOA general and teacher mortality tables (Florida FRS benefit model.R, line 172)
#   special, admin – use SOA safety (Florida FRS benefit model.R, lines 258-264)
#   eco, eso, judges, senior_management - use SOA general (Florida FRS benefit model.R, lines 258-264)


# create the regular table and add it to mort
# general has 626 records, teachers has 616 records when does one have values but not the other
mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  arrange(beneficiary_type, gender, age, employee_type) |>
  group_by(beneficiary_type, gender, age) |>
  mutate(nnotna=sum(!is.na(rate))) |>
  filter(nnotna != 2)
# issue arises for beneficiary_type healthy_retiree male and female ages 50-54 where
#   we have not na values for general but values for teachers are na

# follow the reason approach
regular_mort <- mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  pivot_wider(names_from = beneficiary_type, values_from = rate) |>
  # address missing values in the same way as Reason does
  mutate(employee = ifelse(is.na(employee), healthy_retiree, employee),
         healthy_retiree = ifelse(is.na(healthy_retiree), employee, healthy_retiree)) |>
  pivot_longer(cols = -c(system, employee_type, gender, age),
               names_to = "beneficiary_type",
               values_to = "rate") |>
  # DO NOT use na.rm = TRUE as we have addressed the only case where we have values
  # for one group (general) but not another (teachers)
  summarise(rate=mean(rate), .by=c(system, beneficiary_type, gender, age)) |>
  mutate(employee_type = "regular") |>
  arrange(system, employee_type, beneficiary_type, gender, age)

mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  filter(beneficiary_type ==  "healthy_retiree", gender=="female", age %in% 50:56)
regular_mort |> filter(beneficiary_type ==  "healthy_retiree", gender=="female", age %in% 50:56)

base_mort <- bind_rows(
  mort1 |> filter(employee_type %in% c("general", "safety")),
  regular_mort)

glimpse(base_mort)
count(base_mort, employee_type)

saveRDS(base_mort, path(dfrs, "base_mortality.rds"))


# construct crosswalk between employee class and employee type ------------
# define which base mortality rates to use for each class
class_mortality_xwalk <- tibble(class = frs_constants$classes) |>
  mutate(employee_type =
           case_when(class == "regular" ~ "regular",
                     class %in% c("special", "admin") ~ "safety",
                     class %in% c("eco", "eso", "judges",
                                  "senior_management") ~ "general"))

saveRDS(class_mortality_xwalk, path(dfrs, "class_mortality_xwalk.rds"))


# entry_year_range_ 1970:2052

# expand_grid(entry_year = entry_year_range_, entry_age = entrant_profile$entry_age, dist_age = age_range_, yos = yos_range_) %>%
# mutate(
#   term_year = entry_year + yos,
#   dist_year = entry_year + dist_age - entry_age
# )


# saveRDS(mort, path(dfrs, "mortality_rates.rds")) # one of the files we will save

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

