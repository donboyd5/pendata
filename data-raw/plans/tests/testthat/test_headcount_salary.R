testthat::local_edition(3)
library(testthat)

# source(here::here("R", "setup.R"))
# DIRS <- set_plan_dirs("frs")

hcs_tbl <- readRDS(fs::path(DIRS$work, "hcs_tbl.rds"))


# tests ----

test_that("headcount detail sums equal headcount totals, all age groups", {
  hcsums <- hcs_tbl |>
    filter(
      variable == "headcount",
      age_label != "Total Count"
    ) |>
    summarise(value = sum(value), .by = c(class, age_label, rectype)) |>
    pivot_wider(names_from = rectype)

  expect_equal(hcsums$detail, hcsums$total, tolerance = 1e-8)
})

test_that("headcount detail sums equal headcount totals, all yos groups", {
  hcsums <- hcs_tbl |>
    filter(
      variable == "headcount",
      yos_label != "All Years"
    ) |>
    summarise(value = sum(value), .by = c(class, yos_label, rectype)) |>
    pivot_wider(names_from = rectype)

  expect_equal(hcsums$detail, hcsums$total, tolerance = 1e-8)
})

test_that("headcount detail sums equal headcount totals, grand total", {
  hcsums <- hcs_tbl |>
    filter(
      variable == "headcount",
      rectype == "detail" |
        (age_label == "Total Count" & yos_label == "All Years")
    ) |>
    summarise(value = sum(value), .by = c(class, rectype)) |>
    pivot_wider(names_from = rectype)

  expect_equal(hcsums$detail, hcsums$total, tolerance = 1e-8)
})


test_that("calculated average salaries in totals column (age groups) are within $1 of reported", {
  reported <- hcs_tbl |>
    filter(
      variable == "salary",
      rectype == "total",
      yos_label == "All Years"
    ) |>
    select(class, age_label, value)

  calculated <- hcs_tbl |>
    filter(yos_label != "All Years") |> # rectype == "detail", yos_label != "All Years"
    select(variable, class, yos_label, age_label, value) |>
    pivot_wider(names_from = variable) |>
    mutate(payroll = headcount * salary) |>
    summarise(
      headcount = sum(headcount),
      payroll = sum(payroll),
      .by = c(class, age_label)
    ) |>
    mutate(salary = replace_na(payroll / headcount, 0))

  compare <- left_join(
    reported |>
      select(class, age_label, reported = value),
    calculated |>
      select(class, age_label, calculated = salary),
    by = join_by(class, age_label)
  ) |>
    arrange(desc(abs(calculated - reported)))

  # expect_equal(compare$calculated, compare$reported, tolerance = 1e-8)
  expect_true(all(abs(compare$calculated - compare$reported) < 1)) # relaxed test
})

test_that("calculated average salaries in totals row (yos groups) are within $1 of reported", {
  reported <- hcs_tbl |>
    filter(
      variable == "salary",
      rectype == "total",
      age_label == "Total Count"
    ) |>
    select(class, yos_label, value)

  calculated <- hcs_tbl |>
    filter(age_label != "Total Count") |>
    select(variable, class, yos_label, age_label, value) |>
    pivot_wider(names_from = variable) |>
    mutate(payroll = headcount * salary) |>
    summarise(
      headcount = sum(headcount),
      payroll = sum(payroll),
      .by = c(class, yos_label)
    ) |>
    mutate(salary = replace_na(payroll / headcount, 0))

  compare <- left_join(
    reported |>
      select(class, yos_label, reported = value),
    calculated |>
      select(class, yos_label, calculated = salary),
    by = join_by(class, yos_label)
  ) |>
    arrange(desc(abs(calculated - reported)))

  # expect_equal(compare$calculated, compare$reported, tolerance = 1e-8)
  expect_true(all(abs(compare$calculated - compare$reported) < 1)) # relaxed test
})


test_that("calculated grand total salary is within $1 of reported grand total salary", {
  # NOTE: This will be important if we construct additional details for age groups or yos groups
  reported <- hcs_tbl |>
    filter(
      variable == "salary",
      rectype == "total",
      age_label == "Total Count",
      yos_label == "All Years"
    ) |>
    select(class, reported = value)

  calculated <- hcs_tbl |>
    filter(rectype == "detail") |>
    pivot_wider(names_from = variable) |>
    mutate(payroll = headcount * salary) |>
    summarise(
      headcount = sum(headcount),
      payroll = sum(payroll),
      .by = c(class, rectype)
    ) |>
    mutate(
      salary = replace_na(payroll / headcount, 0)
    ) |>
    select(class, calculated = salary)

  compare <- left_join(
    reported |>
      select(class, reported),
    calculated |>
      select(class, calculated),
    by = join_by(class)
  ) |>
    arrange(desc(abs(calculated - reported)))

  # expect_equal(compare$calculated, compare$reported, tolerance = 1e-8)
  expect_true(all(abs(compare$calculated - compare$reported) < 1)) # relaxed test
})
