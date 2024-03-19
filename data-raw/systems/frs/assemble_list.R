
# About -------------------------------------------------------------------

# Assemble all of the dataframes and other objects for a single retirement
# system into a list that has the same name as the system, and save it to
# the data folder so that it will be available to package users.


# TODO --------------------------------------------------------------------

# Possibly convert this program to a function and put it in a
# functions_utilities.R file, so that it can be used for any system.

# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

# get list with the desired tables -------------------------------------------------------------------

files <- c(
  "base_mortality_rates",
  "class_mortality_xwalk",
  "current_amort_layers",
  "init_funding_data",
  "mortality_rates",
  "mortality_improvement",
  "salary_growth",
  "salary_headcount",
  "entrant_profile",
  "retiree_distribution",
  "retirement_rates",
  "termination_rates"
  ) |> sort()

f <- function(file){
  fpath <- path(dfrs, paste0(file, ".rds"))
  print(fpath)
  readRDS(fpath)
}

frs <- files |>
  set_names() |>
  purrr::map(f)

names(frs)
frs$base_mortality |> ht()
frs$class_mortality_xwalk |> ht()
frs$current_amort_layers |> ht()
frs$init_funding_data |> ht()
frs$mortality_rates |> ht()
frs$mortality_improvement |> ht()
frs$retiree_distribution |> ht()
frs$retirement_rates |> ht()
frs$salary_growth |> ht()
frs$salary_headcount |> ht()
frs$termination_rates |> ht()

usethis::use_data(frs, overwrite = TRUE)
