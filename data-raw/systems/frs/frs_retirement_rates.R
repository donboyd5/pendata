

# setup -------------------------------------------------------------------

source(here::here("data-raw", "libraries.r"))
draw <- here::here("data-raw")

dfrs <- fs::path(draw, "systems", "frs")

dxi <- fs::path(dfrs, "Reports", "extracted inputs")


# get data ----------------------------------------------------------------


fpath <- fs::path(dxi, "normal retirement tier 1.xlsx")

normal_retirement_tier_1_table_ <- read_excel(fpath)


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

