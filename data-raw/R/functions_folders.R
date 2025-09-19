set_plan_dirs <- function(plan) {
  # Base directories
  data <- fs::path(GROOT, "data")
  data_raw <- fs::path(GROOT, "data-raw")
  all_plans_dir <- fs::path(data_raw, "plans")
  plan_dir <- fs::path(all_plans_dir, plan)

  # Return named list
  list(
    # Top-level folders
    data = data,
    data_raw = data_raw,
    all_plans_dir = all_plans_dir,

    # Plan-specific folders
    plan_dir = plan_dir,
    xddir = fs::path(plan_dir, "extracted_data"),
    work = fs::path(plan_dir, "work_data"),
    staged = fs::path(plan_dir, "staged_data")
  )
}
