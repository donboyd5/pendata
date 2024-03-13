
# About -------------------------------------------------------------------

# Get retiree distribution for FRS, from an Excel workbook (Florida FRS
# inputs.xlsx) that Reason created.


# TODO --------------------------------------------------------------------

# Look for additional cleanup code that Reason has in other files and
# consolidate it here.

# Not sure where these data come from. Find out and document.

# Read as text, convert to desired types.


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

FileName <- "Florida FRS inputs.xlsx"
fullpath  <- fs::path(dfrs, FileName)


# get and save data ----------------------------------------------------------------

retiree_distribution <- read_excel(fullpath, sheet = "Retiree Distribution")

glimpse(retiree_distribution)

skim(retiree_distribution)
retiree_distribution |>
  summarise(across(-age, sum))

saveRDS(retiree_distribution, path(dfrs, "retiree_distribution.rds"))
