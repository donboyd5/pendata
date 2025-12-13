test_that("frs top-level reduced and staged/gang objects moved into params_env", {
  # load the installed package and final data
  library(pendata)
  frs_installed <- pendata::frs

  # only plan_shortname and params_env should be top-level
  expect_setequal(names(frs_installed), c("plan_shortname", "params_env"))

  # params_env should be a list and should not contain plan_shortname
  expect_true(is.list(frs_installed$params_env))
  expect_false("plan_shortname" %in% names(frs_installed$params_env))

  # staged names must be present in params_env
  load(file.path("data-raw", "plans", "frs", "work_data", "frs.rda"))
  staged_names <- setdiff(names(frs), "plan_shortname")
  missing_staged <- setdiff(staged_names, names(frs_installed$params_env))
  expect_length(missing_staged, 0)

  # Gang-needed objects should be present in params_env
  gang_needed <- c(
    "salary_headcount_table",
    "mort_table",
    "mort_retire_table",
    "separation_rate_table",
    "entrant_profile_table",
    "dr_lookup",
    "cola_lookup",
    "ben_mult_lookup",
    "reduce_factor_lookup",
    "tier_table",
    "fas_period_lookup"
  )
  missing_gang <- setdiff(gang_needed, names(frs_installed$params_env))
  expect_length(missing_gang, 0)
})
