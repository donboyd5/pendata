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

init_funding_data <- read_excel(fullpath, sheet = "Funding Input")

saveRDS(init_funding_data, fs::path(dfrs, "init_funding_data.rds"))



