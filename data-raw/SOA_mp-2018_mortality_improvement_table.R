

# setup -------------------------------------------------------------------

source(here::here("R", "libraries.r"))

draw <- here::here("data-raw")

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
