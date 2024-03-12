

# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

dxi <- fs::path(dfrs, "Reports", "extracted inputs")


# functions ---------------------------------------------------------------
combine <- function(prefixes, suffixes){
  # paste two string vectors as follows:
  # for example if prefixes = c("a", "b", "c") and suffixes = c("1", "2")
  # the result would be c("a_1", "a_2", "b_1", "b_2", "c_1", "c_2") in that order
  outer(prefixes, suffixes, FUN = paste, sep = "_") |>
    t() |>
    c()
}


# get and save raw retirement rates data ----------------------------------------------------------------

# normal_retirement_tier_1_table_ <- read_excel(fpath)

# drop, normal, and early, tier 1 and tier2

fpath <- fs::path(dxi, "normal retirement tier 1.xlsx")

# create lists of column name prefixes (gender will be suffix)
normal_pre <- c("regular_k12_instructional", "regular_nonk12_instructional",
  "special_risk_all", "elected_officers", "senior_management")

early_pre <- normal_pre[-1]

drop_pre <- c("regular_k12_instructional", "regular_nonk12_instructional",
              "special_risk_xleo", "special_risk_leo", "other")

gender <- c("female", "male")

normal <- list(fnbase="normal retirement", cols=combine(normal_pre, gender))
early <- list(fnbase="early retirement", cols=combine(early_pre, gender))
drop <- list(fnbase="drop entry", cols=combine(drop_pre, gender))

rrlist <- list(normal, early, drop)
rrlist[[1]]

info <- rrlist[[3]]
# purrr::map(\(x) get_mort(x, fullpath)) |>

#   index_of_70_79_row <- which(df[,1] == "70-79")
#
#   names(df) <- col_names
#
#   df <- df %>%
#     add_row(age=as.character(71:79), .after=index_of_70_79_row) %>%
#     mutate(
#       age = replace(age, age == "70-79", "70"),
#       across(everything(), ~as.numeric(.x))
#     ) %>%
#     fill(everything(), .direction = "down")

get_retrates <- function(info, rrpath=dxi){
  fnames <- paste0(info$fnbase, c(" tier 1", " tier 2"), ".xlsx")
  fpaths <- fs::path(rrpath, fnames)
  #fpath <- fpaths[2]
  colnames <- c("agec", info$cols) # agec means age as character

  get_df <- function(fpath){
    print(fpath)
    tier <- str_sub(fpath, -11, -6) |>
      str_remove(" ")

    df1 <- read_excel(fpath,
                      sheet = 1,
                      range = cellranger::cell_cols(1:length(colnames)),
                      col_names = colnames,
                      col_types = "text")

    # we only want rows for which age is good
    first_data_row <- which(df1$agec=="Age")[1] + 1

    # last data row is last not-na row after first data row
    na_indices <- which(is.na(df1$agec))
    last_data_row <- na_indices[na_indices > first_data_row][1] - 1

    df2 <- df1 |>
      slice(first_data_row:last_data_row) |>
      mutate(system="frs", rtype=info$fnbase, tier=tier) |>
      pivot_longer(cols=-c(system, rtype, tier, agec),
                   values_to = "rate") |>
      filter(!is.na(rate)) |>
      select(system, rtype, tier, name, agec, rate)

    df2
  }
  bind_rows(get_df(fpaths[1]), get_df(fpaths[2]))
}

tmp <- get_retrates(rrlist[[2]])
count(tmp, agec)

rrates_raw <- rrlist |>
  purrr::map(get_retrates) |>
  list_rbind() |>
  separate(name, into = c("vname", "gender"), sep = "_(?=[^_]+$)", remove = TRUE)

count(rrates_raw, agec)
glimpse(rrates_raw)

saveRDS(rrates_raw, path(dfrs, "rrates_raw.rds"))


# clean retirement rates --------------------------------------------------
# see  Florida FRS benefit model.R clean_retire_rate_table
rrraw <- readRDS(path(dfrs, "rrates_raw.rds"))
ht(rrraw)

rrraw$agec |> unique() |> sort()

# we need to fill in the 70-79 age group by repeating 70 - interpolation probably better

# function to replace 70-79 with 10 rows like 70

rr2 <- rrraw |>
  mutate(reps=ifelse(agec=="70-79", 10, 1)) |>
  uncount(reps) |> # 10 copies of each 70-79 record
  mutate(age=as.numeric(agec),
         rate=as.numeric(rate)) |>
  mutate(age=ifelse(agec=="70-79", 70:79, age), .by=c(system, rtype, tier, vname, gender))
count(rr2, agec, age)

ht(rr2)

rr3 <- rr2 |>
  select(system, rtype, tier, vname, gender, age, rate)

ht(rr3)
skim(rr3)
saveRDS(rr3, path(dfrs, "retirement_rates.rds"))


# Retirement rate tables source: Florida FRS model input.R

# drop_entry_tier_1_table_ <- read_excel("Reports/extracted inputs/drop entry tier 1.xlsx")
# drop_entry_tier_2_table_ <- read_excel("Reports/extracted inputs/drop entry tier 2.xlsx")
#
# normal_retirement_tier_1_table_ <- read_excel("Reports/extracted inputs/normal retirement tier 1.xlsx")
# normal_retirement_tier_2_table_ <- read_excel("Reports/extracted inputs/normal retirement tier 2.xlsx")
#
# early_retirement_tier_1_table_ <- read_excel("Reports/extracted inputs/early retirement tier 1.xlsx")
# early_retirement_tier_2_table_ <- read_excel("Reports/extracted inputs/early retirement tier 2.xlsx")


# source: Florida FRS benefit model.R
# clean_retire_rate_table <- function(df, col_names){
#
#   index_of_na_row_from_bottom <- tail(which(rowSums(is.na(df)) == ncol(df)),1)
#   index_of_row_before_body <- which(df[,1] == "Age")
#
#   df <- df %>%
#     slice(-(index_of_na_row_from_bottom:n())) %>%
#     slice(-(1:index_of_row_before_body)) %>%
#     select_if(~any(!is.na(.)))
#
#   index_of_70_79_row <- which(df[,1] == "70-79")
#
#   names(df) <- col_names
#
#   df <- df %>%
#     add_row(age=as.character(71:79), .after=index_of_70_79_row) %>%
#     mutate(
#       age = replace(age, age == "70-79", "70"),
#       across(everything(), ~as.numeric(.x))
#     ) %>%
#     fill(everything(), .direction = "down")
#
#   return(df)
# }

