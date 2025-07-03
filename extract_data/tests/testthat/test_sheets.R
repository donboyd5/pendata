# tests/test_sheets.R

testthat::local_edition(3)
library(testthat)

source(here::here("R", "folders.R"))
source(fs::path(DXDATA, "plan_name.R"))

fname <- paste0(plan, "_inputs_raw.rds")
input_data_list <- readRDS(fs::path(xddir, fname))

# sheets <- readxl::excel_sheets(xdpath)
sheets <- names(input_data_list)
# note that deepseek prefers we not create sheets as a global variable

test_that("Workbook has required exact-match sheets", {
  required_sheets <- c(
    "benefit_rules",
    "constants_assumptions",
    "constants_funding",
    "salarygrowth"
  )
  cat("\n## Testing for existence of following required sheets:\n")
  cat(paste(required_sheets, collapse = ", "), "\n")

  expect_true(all(required_sheets %in% sheets))
})

test_that("Workbook has at least one headcount_ sheet", {
  headcount_sheets <- grep("^headcount_", sheets, value = TRUE)
  expect_gte(length(headcount_sheets), 1)
})

test_that("Workbook has at least one salary_ sheet (not counting salary_growth)", {
  salary_sheets <- grep(
    "^salary_",
    setdiff(sheets, "salary_growth"),
    value = TRUE
  )
  expect_gte(length(salary_sheets), 1)
})
