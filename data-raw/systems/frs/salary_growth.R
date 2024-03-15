# About -------------------------------------------------------------------

# frs: Florida Retirement System

# Get salary growth table for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.


# The format of the salary growth table is:
#   system, string, frs
#   class, string, any of special, admin, eco, eso, judges, senior_management
#   yos integer, years of service
#   salgrowth, growth rate vs. prior yos


# The format of the salary and headcount table is:


# TODO --------------------------------------------------------------------


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.R"))

draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")
source(fs::path(dfrs, "constants.R"))
frs_constants

FileName <- "Florida FRS inputs.xlsx"
fullpath <- fs::path(dfrs, FileName)


# get salary growth table -------------------------------------------------

# Truong reads this in "Florida FRS model input.R" line 180 and extends it
# to OUR maximum yos in "Florida FRS benefit model.R" lines 6-9 by carrying the
# last yos growth rate (yos=70) forward to all subsequent yos (up to 70)
# He then establishes cumulative growth rates.

salgrowth1 <- read_excel(fullpath, sheet = "Salary Growth", col_types = "text")

salgrowth2 <- salgrowth1 |>
  pivot_longer(-yos, names_to = "class", values_to = "salgrowth") |>
  mutate(
    yos = as.integer(yos),
    class = str_remove(class, "salary_increase_"),
    # fix inconsistent naming
    class = ifelse(class == "special_risk", "special", class),
    salgrowth = as.numeric(salgrowth),
    system="frs"
  ) |>
  select(system, class, yos, salgrowth)

glimpse(salgrowth2)
skim(salgrowth2)
ht(salgrowth2)

# save salary growth table now because we may want option of using different
# salary growths -- that might be better done in the model

saveRDS(salgrowth2, path(dfrs, "salary_growth_raw.rds"))


# extend salary growth table to max yos and calculate cumulative growth -------
# cumprod(1 + lag(.x, default = 0))
salgrowth2 <- readRDS(path(dfrs, "salary_growth_raw.rds"))
salgrowthx <- crossing(salgrowth2 |>
                         select(system, class),
                       yos=0:frs_constants$yos_max) |>
  left_join(salgrowth2, by = join_by(system, class, yos)) |>
  arrange(system, class, yos) |>
  group_by(system, class) |>
  fill(salgrowth, .direction = "down") |>
  mutate(cumprod_increase=cumprod(1 + lag(salgrowth, default = 0))) |>
  ungroup()

saveRDS(salgrowthx, path(dfrs, "salary_growth.rds"))




