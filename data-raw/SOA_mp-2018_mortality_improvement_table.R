

# setup -------------------------------------------------------------------

draw <- here::here("data-raw")

source(path(draw, "libraries.r"))



# mortality improvement scales ----

# download the MP-2018 documentation and tables from the SOA site MP-2018 was
# released in 2018 -- see SOA documentation data for calendar years 1950 through
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



# extend mp2018 to more ages and years ------------------------------------

# extend mp1
# mp1 <- readRDS(fs::path(draw, "mp-2018.rds"))

mp1 <- mp2018

add_younger <- function(df){
  addrows <- bind_rows(df[1, ],
                       df[1, ])|>
    mutate(age=18:19)

  bind_rows(addrows, df) # return the new, longer data frame
}

df <- mp1 |> filter(gender=="female", age==22); endyear <- 2039

add_years <- function(df, endyear){
  current_endyear <- max(df$year)

  ultimate_rate <- df |>
    filter(year==current_endyear) |>
    pull(mp)

  add_rows <- tibble(year=(current_endyear + 1):endyear,
                     mp=ultimate_rate)

  bind_rows(df, add_rows)
}

mp2 <- mp1 |>
  arrange(gender, year, age) |>
  reframe(add_younger(pick(everything())), .by=c(gender, year)) |>
  reframe(add_years(pick(everything()), endyear=2154), .by=c(gender, age)) |>
  arrange(gender, age, year) |>
  mutate(mpc=cumprod(1 - mp), .by=c(gender, age)) # cumulative improvement from earliest year to latest

tmp <- mp2 |>
  filter(gender=="male", age==18)

# great - now we can get cumulative improvement from earliest year to latest, for each gender-age group
# adjusted value is ratio of raw value and the anchor point in base year
base_year <- 2010

mp3 <- mp2 |>
  mutate(mpcadj=mpc / mpc[year==base_year], .by=c(gender, age))

tmp <- mp3 |>
  filter(gender=="male", age==18)


mp_extend <- function(mptable, startage=18, endyear=2154, baseyear=2010){
  # will extend any mp table with additional ages or years

  mptablex <- mptable |>
    arrange(gender, year, age) |>
    reframe(add_younger(pick(everything())), .by=c(gender, year)) |>
    reframe(add_years(pick(everything()), endyear), .by=c(gender, age)) |>
    arrange(gender, age, year) |>
    mutate(mpc=cumprod(1 - mp), .by=c(gender, age)) |> # cumulative improvement from earliest year to latest
    mutate(mpcadj=mpc / mpc[year==baseyear], .by=c(gender, age)) # rebase

  mptablex
}

mp3 <- mp_extend(mp1, startage=18, endyear=2154, baseyear=2010)



