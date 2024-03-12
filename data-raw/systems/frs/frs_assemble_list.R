
# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

# get list with the desired tables -------------------------------------------------------------------

files <- c("mortality_rates", "mortality_improvement", "salary_growth_extended",
           "salary_headcount", "entrant_profile", "retirement_rates") |> sort()

f <- function(file){
  fpath <- path(dfrs, paste0(file, ".rds"))
  print(fpath)
  readRDS(fpath)
}

frs <- files |>
  set_names() |>
  purrr::map(f)

names(frs)
frs$mortality_rates |> ht()
frs$mortality_improvement |> ht()
frs$retirement_rates |> ht()
frs$salary_growth |> ht()
frs$salary_headcount |> ht()

usethis::use_data(frs, overwrite = TRUE)
