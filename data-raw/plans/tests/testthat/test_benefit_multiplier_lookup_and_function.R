testthat::local_edition(3)
library(testthat)
library(dplyr)

fname <- paste0(PLAN_CONSTANTS$plan, "_inputs_raw.rds")
rawdata <- readRDS(fs::path(DIRS$work, fname))
# names(rawdata)

# Source benefit-multiplier functions
source(fs::path(DIRS$plan_dir, "R", "benefit_functions.R"))
source(fs::path(DIRS$plan_dir, "R", "lookup_functions.R"))

benefit_rules <- rawdata[["benefit_rules"]]$data |>
  mutate(
    across(c(dist_age_min_ge:dist_year_max_lt, benmult), as.numeric),
    early_retirement = as.logical(early_retirement)
  )

test_cases <- rawdata[["benefit_rules_test_cases"]]$data |>
  mutate(
    across(dist_age:expected_benmult, as.numeric),
    early_retirement = as.logical(early_retirement)
  )

test_that("benmult_function matches expected benmult", {
  tc <- test_cases |>
    filter(dist_year > 0) |> # dist_year == 0 is oddball special_risk situation
    mutate(benmult_function = benmult_function(pick(everything())))

  expect_equal(tc$benmult_function, tc$expected_benmult, tolerance = 1e-8)
})

test_that("benmult_lookup matches expected benmult", {
  tc <- test_cases |>
    filter(dist_year > 0) |> # dist_year == 0 is oddball special_risk situation
    mutate(benmult_lookup = benmult_lookup(pick(everything()), benefit_rules))

  expect_equal(tc$benmult_lookup, tc$expected_benmult, tolerance = 1e-8)
})

test_that("benmult_function and benmult_lookup agree", {
  tc <- test_cases |>
    filter(dist_year > 0) |>
    mutate(
      benmult_function = benmult_function(pick(everything())),
      benmult_lookup = benmult_lookup(pick(everything()), benefit_rules)
    )

  expect_equal(tc$benmult_function, tc$benmult_lookup, tolerance = 1e-8)
})
