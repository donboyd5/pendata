# About -------------------------------------------------------------------

# frs: Florida Retirement System

# Get salary and headcount tables for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.

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
source(fs::path(dfrs, "functions.R"))
source(fs::path(dfrs, "constants.R"))

# create final salary_headcount table ----
# desired final columns:
# system, class, entry_year, entry_age, age, yos, count, entry_salary
sg1 <- readRDS(path(dfrs, "salary_growth.rds"))
sal1 <- readRDS(path(dfrs, "salary.rds"))
hc1 <- readRDS(path(dfrs, "headcount.rds"))



salary_headcount <- hc1 |>
  left_join(sal1, by = join_by(system, class, age, yos)) |>
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

