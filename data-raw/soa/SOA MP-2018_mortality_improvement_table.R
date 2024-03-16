
# SOA Mortality improvement tables mp-2018.

# This program gets the Society of Actuaries mortality improvement
# table MP-2018 and saves a raw version of it (i.e., with the data exactly
# as provided by SOA) as a long dataframe.


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

# mortality improvement scales ----

# download the MP-2018 documentation and tables from the SOA site MP-2018 was
# released in 2018 -- see SOA documentation. Data for calendar years 1950 through
# 2014 were taken directly from SSA-published smoothed mortality rates from 2018
# SSA Trustees report

# https://www.soa.org/49964f/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018.pdf
udoc <- "https://www.soa.org/49964f/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018.pdf"
download.file(udoc,
              fs::path(draw, "documentation", fs::path_file(udoc)),
              mode = "wb")

urates <- "https://www.soa.org/493456/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018-rates.xlsx"
download.file(urates,
              fs::path(draw, fs::path_file(urates)),
              mode = "wb")


# read the male and female tables -----------------------------------------

# system.time(df1 <- read_excel(fpath, sheet = "Male"))
# system.time(df1 <- read_excel(fpath, sheet = "Male", range="A2:CG103")) # much faster

udoc <- "https://www.soa.org/49964f/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018.pdf"
urates <- "https://www.soa.org/493456/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018-rates.xlsx"
fpath <- path(draw, path_file(urates))
dfm <- read_excel(fpath, sheet = "Male", range = "A2:CG103")
dff <- read_excel(fpath, sheet = "Female", range = "A2:CG103")


## get a long raw mortality improvement table ----

mp2018 <- bind_rows(dfm |>
                      mutate(gender = "male"),
                    dff |>
                      mutate(gender = "female")) |>
  rename_with(.fn = ~ str_replace(.x, "\\+", ""),
              .col = ends_with("+")) |>
  rename(age = 1) |>
  mutate(age = str_remove(age, "≤ ") |> as.integer()) |>
  pivot_longer(-c(gender, age), names_to = "year", values_to = "mp") |>
  mutate(year = as.integer(year)) |>
  select(gender, year, age, mp) |>
  arrange(gender, year, age)

usethis::use_data(mp2018, overwrite = TRUE)


# Check: extend mp2018 to more ages and years ------------------------------------

# mp1 <- readRDS(fs::path(draw, "mp-2018.rds"))
# mp1 <- mp2018

mp1 <- pendata::mp2018
skim(mp1) # 1951-2034, ages 20-120

# extend years to 2154, age down to 18, and index to baseyear 2010
mp2 <- pendata::extend_mp(mp1, startage=18, endyear=2154, baseyear=2010)
skim(mp2)

mp2 |>
  filter(year %in% 2009:2011, gender=="female", age %in% 18:21)

glimpse(mp2)
ht(mp2)
count(mp2, gender)
count(mp2, age) |> ht()
count(mp2, year) |> ht()



