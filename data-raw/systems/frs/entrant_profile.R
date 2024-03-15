# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.R"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")
source(fs::path(dfrs, "functions.R"))
source(fs::path(dfrs, "constants.R"))


# get data ----------------------------------------------------------------


# create entrant profile --------------------------------------------------

salary_headcount <- readRDS(path(dfrs, "salary_headcount.rds"))

# why does Truong want so many older people in his entrants' profile??
entrant_profile <- salary_headcount |>
  filter(entry_year == max(entry_year)) |>
  mutate(entrant_dist = count/sum(count), .by=c(system, class)) |>
  select(system, class, entry_age, start_sal=entry_salary, entrant_dist)

saveRDS(entrant_profile, path(dfrs, "entrant_profile.rds"))

