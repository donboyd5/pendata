# About -------------------------------------------------------------------

# frs: Florida Retirement System

# Get ...

# TODO --------------------------------------------------------------------

# figure out what to do with this....

# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.R"))

draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")
source(fs::path(dfrs, "constants.R"))
frs_constants

FileName <- "Florida FRS inputs.xlsx"

fullpath <- fs::path(dfrs, FileName)

# get and save data ------------------------------------------------------

amort1 <- read_excel(fullpath,
                     sheet = "Amort Input",
                     col_types = "text")

amort2 <- amort1 |>
  mutate(system="frs",
         date=mdy(date),
         amo_period=as.numeric(amo_period),
         amo_balance=as.numeric(amo_balance)) |>
  relocate(system)

skim(amort2)
amort2 |> filter(is.na(amo_period))
# amo_period is NA in the source data for June 30, 2019

saveRDS(amort2, fs::path(dfrs, "current_amort_layers.rds"))

