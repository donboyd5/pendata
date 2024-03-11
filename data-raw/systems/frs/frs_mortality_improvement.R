
# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

# mp1 <- readRDS(fs::path(draw, "mp-2018.rds"))
# mp1 <- mp2018


# get SOA MP-2018 mortality improvement table -----------------------------

mp1 <- pendata::mp2018
skim(mp1) # 1951-2034, ages 20-120

# for FRS, extend years to 2154, age down to 18, and index to baseyear 2010 ---
mp2 <- pendata::extend_mp(mp1, startage=18, endyear=2154, baseyear=2010) |>
  mutate(system="frs") |>
  relocate(system)
skim(mp2)
ht(mp2)

mp2 |>
  filter(year %in% 2009:2011, gender=="female", age %in% 18:21)

glimpse(mp2)
ht(mp2)
count(mp2, gender)
count(mp2, age) |> ht()
count(mp2, year) |> ht()

saveRDS(mp2, path(dfrs, "mortality_improvement.rds"))
