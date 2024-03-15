# About -------------------------------------------------------------------

# frs: Florida Retirement System

# Get salary and headcount tables for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.

# The format of the salary and headcount table is:

# CAUTION: This relies on salary_growth.rds, which is created in salary_growth.R


# TODO --------------------------------------------------------------------

# Consider:
#   - breaking entrant_profile out into separate R file
#   - separate files for salary_headcount_raw, which just relies on one sheet, and
#       salary_headcount, which requires ..._raw plus salary_growth


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.R"))

draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")
source(fs::path(dfrs, "constants.R"))
frs_constants

FileName <- "Florida FRS inputs.xlsx"


# functions ---------------------------------------------------------------

get_class <- function(class_tabname){
  # map Excel sheet names that represent classes to the class names that Reason
  # uses in the model example: get_class(c("Sen Man", "Judge"))

  class_mapping <- c(regular="Regular", special="Special", admin="Admin",
                     eco="Eco", eso="Eso", judges="Judge",
                     senior_management="Sen Man")

  indexes <- match(class_tabname, class_mapping)

  model_names <- names(class_mapping)[indexes]
  model_names
}


# get data ----------------------------------------------------------------
# my approach is get all the raw data and clean it before combining with other files
fullpath <- fs::path(dfrs, FileName)

tabs <- excel_sheets(fullpath)


# explore tabs ----------------------------------------------------------

tabs |> str_subset("Regular")
tabs |> str_subset("HeadCount Distribution") # e.g., HeadCount Distribution Sen Man
tabs |> str_subset("Salary Distribution")

# hcnames <- tabs |> str_subset("HeadCount Distribution") |> str_remove("HeadCount Distribution ")



# get all of the headcount tables ----
hctabs <- tabs |>
  str_subset("HeadCount")

get_headcount <- function(hcsheet){
  # read a headcount sheet, pivot and clean, return a tibble

  class_tabname <- str_remove(hcsheet, "HeadCount Distribution ") # notice ending space
  class <- get_class(class_tabname)

  print(class)

  hc1 <- read_excel(fullpath, hcsheet, col_types = "text")
  hc2 <- hc1 |>
    pivot_longer(-age, names_to = "yos", values_to = "count") |>
    mutate(
      class = class,
      age = as.integer(age),
      yos = as.integer(yos),
      count = as.numeric(count)
    ) |>
    relocate(class)
  hc2
}

headcount_table <- purrr::map(hctabs, get_headcount) |>
  list_rbind() |>
  arrange(class, age, yos)


# get all of the salary tables ----
saltabs <- tabs |>
  str_subset("Salary Distribution ")

get_salaries <- function(salsheet){
  # read a headcount sheet, pivot and clean, return a tibble

  class_tabname <- str_remove(salsheet, "Salary Distribution ") # notice ending space
  class <- get_class(class_tabname)

  print(class)

  sal1 <- read_excel(fullpath, salsheet, col_types = "text")
  sal2 <- sal1 |>
    pivot_longer(-age, names_to = "yos", values_to = "salary") |>
    mutate(
      class = class,
      age = as.integer(age),
      yos = as.integer(yos),
      salary = as.numeric(salary)
    ) |>
    relocate(class)
  sal2
}

salary_table <- purrr::map(saltabs, get_salaries) |>
  list_rbind() |>
  arrange(class, age, yos)


# combine headcounts and salaries and save, as they go together -----------

nrow(headcount_table) == nrow(salary_table)  # should be TRUE

salary_headcount_table <- headcount_table |>
  full_join(salary_table,
            by = join_by(class, age, yos)) |>
  mutate(system="frs") |>
  relocate(system)

glimpse(salary_headcount_table)
ht(salary_headcount_table)
skim(salary_headcount_table)

saveRDS(salary_headcount_table, path(dfrs, "salary_headcount_raw.rds"))

# create final salary_headcount table ----
# desired final columns:
# system, class, entry_year, entry_age, age, yos, count, entry_salary
sg1 <- readRDS(path(dfrs, "salary_growth.rds"))
sh1 <- readRDS(path(dfrs, "salary_headcount_raw.rds"))

salary_headcount <- sh1 |>
  mutate(start_year = frs_constants$start_year,
         entry_age = age - yos,
         entry_year = start_year - yos) |>
  filter(!is.na(salary), entry_age >= 18) |>  # why do we have unneeded years?
  left_join(sg1, by = join_by(system, class, yos)) |>
  mutate(entry_salary = salary / cumprod_increase) |>
  select(system, class, entry_year, entry_age, age, yos, count, entry_salary)

saveRDS(salary_headcount, path(dfrs, "salary_headcount.rds"))


# create entrant profile --------------------------------------------------
# why does Truong want so many older people in his entrants' profile??
entrant_profile <- salary_headcount |>
  filter(entry_year == max(entry_year)) |>
  mutate(entrant_dist = count/sum(count), .by=c(system, class)) |>
  select(system, class, entry_age, start_sal=entry_salary, entrant_dist)

saveRDS(entrant_profile, path(dfrs, "entrant_profile.rds"))


# Truong's code below, commented out ----------------------------

# Truong gets:
#   salary growth
#   headcount tables
#   salary tables
#   entrant profiles

# He processes eco, eso, and judges separately because "acfr does not provide detailed headcounts"
#   note that the headcounts come from appendix c of the AV, not the ACFR
#   could the so-called less detail simply reflect (1) older start ages for judges, plus
#  (2) either mandatory retirement, or newer plans meaning they don't yet have longer yos???

# Truong deals with this by calculating a special eco eso judges adjustment ratio as the
#   ratio of total eej active members to the sum of active members in the headcount tables
#   for grossing up cell counts so that they hit totals that is different from the gross up he uses
#   for regular, special, etc.; I don't yet know why



# salary_growth_table_ <- read_excel(FileName, sheet = "Salary Growth")
#
# regular_salary_table_ <- read_excel(FileName, sheet="Salary Distribution Regular")
# regular_headcount_table_ <- read_excel(FileName, sheet="HeadCount Distribution Regular") %>%
#   mutate(across(everything(), ~replace(.x, is.na(.x), 0)))
#
# regular_salary_headcount_table <- get_salary_headcount_table(
#   regular_salary_table_,
#   regular_headcount_table_,
#   salary_growth_table,
#   "regular")$salary_headcount_table
#
# regular_entrant_profile_table <- get_salary_headcount_table(
#   regular_salary_table_,
#   regular_headcount_table_,
#   salary_growth_table, "regular")$entrant_profile

# after getting the raw data, Truong's key function is get_salary_headcount_table
# he calls it as follows:
#   regular - 2x returns salary_headcount_table, entrant_profile
#   same for special, admin, eco, eso, judges, senior_management


# Joining headcount data, salary data, and salary growth data

# We account for the Investment Plan (DC plan) head count by inflating the DB head count by the ratio of total system head count to DB head count

# ECO, ESO, and Judges head counts are processed separately as the ACFR does not provide detailed head counts for these classes
# eco_eso_judges_active_member_adjustment_ratio <- eco_eso_judges_total_active_member_ / sum(eco_headcount_table_[-1] + eso_headcount_table_[-1] + judges_headcount_table_[-1])

# total active members (for grossing up) are defined in lines 160+ of Florida FRS model input.R
# they come from numbered page 163 of the ACFR
#Below are the total membership numbers for each membership class. These numbers are from the ACFR and include both DB and DC membership.
# regular_total_active_member_ <- 537128
# special_total_active_member_ <- 72925
# admin_total_active_member_ <- 104
# eco_eso_judges_total_active_member_ <- 2075
# senior_management_total_active_member_ <- 7610



# get_salary_headcount_table <- function(salary_table, headcount_table, salary_growth_table, class_name){
#
#   class_name <- str_replace(class_name, " ", "_")
#
#   if (!class_name %in% c("eco", "eso", "judges")) {
#     assign("total_active_member", get(paste0(class_name, "_total_active_member_")))
#   } else {
#     assign("total_active_member", get("eco_eso_judges_total_active_member_"))
#   }
#
#   salary_growth_table <- salary_growth_table %>%
#     select(yos, contains(class_name)) %>%
#     rename(cumprod_salary_increase = 2)
#
#   salary_table_long <- salary_table %>%
#     pivot_longer(cols = -1, names_to = "yos", values_to = "salary")
#
#   headcount_table_long <- headcount_table %>%
#     pivot_longer(cols = -1, names_to = "yos", values_to = "count") %>%
#     mutate(
#       active_member_adjustment_ratio = if_else(str_detect(class_name, "eco|eso|judges"), eco_eso_judges_active_member_adjustment_ratio,
#                                                total_active_member / sum(count, na.rm = T)),
#       count = count * active_member_adjustment_ratio
#     ) %>%
#     select(-active_member_adjustment_ratio)
#
#   salary_headcount_table <- salary_table_long %>%
#     left_join(headcount_table_long) %>%
#     mutate(
#       yos = as.numeric(yos),
#       start_year = start_year_,
#       entry_age = age - yos,
#       entry_year = start_year - yos) %>%
#     filter(!is.na(salary), entry_age >= 18) %>%
#     left_join(salary_growth_table) %>%
#     mutate(entry_salary = salary / cumprod_salary_increase) %>%
#     select(entry_year, entry_age, age, yos, count, entry_salary)
#
#   entrant_profile <- salary_headcount_table %>%
#     filter(entry_year == max(entry_year)) %>%
#     mutate(entrant_dist = count/sum(count)) %>%
#     select(entry_age, entry_salary, entrant_dist) %>%
#     rename(start_sal = entry_salary)
#
#   output <- list(
#     salary_headcount_table = salary_headcount_table,
#     entrant_profile = entrant_profile)
#
#   return(output)
# }



