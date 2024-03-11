
# frs: Florida Retirement System

# This program gets mortality tables for FRS, from an
# Excel workbook that Reason created.


# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")


# functions ---------------------------------------------------------------

get_mort <- function(sheet, fullpath){
  # read a single frs mortality table from a given sheet
  # create a long mortality table

  # each sheet has the class (e.g., teacher, safety, etc.) in A2
  class <- read_excel(fullpath, sheet = sheet, range="A2", col_names = "class") |>
    pull(class) |>
    str_to_lower()
  print(class)

  # get the raw mortality table, which we will clean
  mort1 <- suppressMessages(
    read_excel(fullpath,
               sheet = sheet,
               skip=3,
               col_names = FALSE,
               col_types="text")
  )

  # identify columns to drop: value in row 2 (variable names) is missing
  cols_to_drop <- mort1[2, ] |>
    unlist(use.names = FALSE) |>
    is.na()

  mort2 <- mort1[, !cols_to_drop]

  # create gender vector, telling which columns are male or female
  # pull gender values from first row
  gender <- mort2[1, 2:ncol(mort2)] |> # first row has gender
    unlist(use.names = FALSE) |> # convert to vector
    # carry forward (to the right) the nonmissing value, "male" or "female"
    # locf stands for "last observation carry forward"
    zoo::na.locf0() |>
    str_remove("^.*?; ") |> # remove everything before first "; "
    str_to_lower() |>
    str_sub(1, -2) # remove s on the end
  # we now have a vector such as c("male", "male", "male", "female", ...)

  # pull variable names from 2nd row
  colnames_base <- mort2[2, ] |>
    unlist(use.names = FALSE) |>
    str_replace_all(" ", "_") |>
    str_remove_all("\\*") |>
    str_to_lower()

  # column names have values such as healthy_retiree__male ...
  colnames <- c(colnames_base[1],
                # use double underscore to make separation easy later
                paste0(colnames_base[-1], "__", gender))

  mort3 <- mort2 |>
    setNames(colnames) |>
    filter(row_number() > 2) |>
    mutate(age=as.integer(age)) |>
    pivot_longer(-age, values_to = "rate") |>
    # here's where the double underscore is helpful
    separate(name, into=c("emptype", "gender"), sep = "__") |>
    mutate(class=class, rate=as.numeric(rate)) |>
    select(class, emptype, gender, age, rate) |>
    arrange(class, emptype, gender, age)

  mort3 # return a long mortality table for a single sheet
}


# mortality tables --------------------------------------------------------

# general, teacher, and safety all involve the same cleaning

fname <- "pub-2010-headcount-mort-rates.xlsx"
fullpath <- fs::path(dfrs, fname)
sheets <- c("PubT.H-2010", "PubS.H-2010", "PubG.H-2010") # teacher, safety general

mort <- sheets |>
  purrr::map(\(x) get_mort(x, fullpath)) |>
  list_rbind() |>
  pivot_wider(names_from = gender, values_from = rate) |>
  mutate(all=(male + female) / 2) |>
  pivot_longer(cols=c(male, female, all),
               names_to = "gender", values_to = "rate") |>
  mutate(system="frs") |>
  select(system, class, emptype, gender, age, rate)

count(mort, class)
count(mort, emptype)
count(mort, gender)
names(mort)
ht(mort)

saveRDS(mort, path(dfrs, "mortality_rates.rds")) # one of the files we will save

# later, we will gather up all of the files for a system and put them into
# a big list for the system e.g., frs$mort_rates, frs$salary_scale
# that can be loaded into the model



# readRDS(path(ddir, "mort_rates.rds"))

# note that Truong also does the following in the benefit model
# Create this mort table for regular employees who are either teachers or general employees
#   base_regular_mort_table <- (base_general_mort_table + base_teacher_mort_table)/2
# in other words, he uses the average for teachers and general, but not for safety??

# this is addressed in the table above by creating "all" rows for the gender
# column, which is the average for everything

