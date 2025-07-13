set_plan_dirs <- function(plan) {
  # Base directories
  data <- here::here("data")
  data_raw <- here::here("data-raw")
  plans_dir <- fs::path(data_raw, "plans")
  plan_dir <- fs::path(plans_dir, plan)

  # Return named list
  list(
    # Top-level folders
    data = data,
    extract_data = fs::path(data_raw, "extract_data"),

    # Plan-specific folders
    plan_dir = plan_dir,
    xddir = fs::path(plan_dir, "extracted_data"),
    work = fs::path(plan_dir, "work_data"),
    staged = fs::path(plan_dir, "staged_data"),
    prep_code = fs::path(data_raw, "prepare_data", plan)
  )
}

# plan_xdfile = fs::path(
#   plan_dir,
#   "extracted_data",
#   plan_constants$xd_filename
# ),
