set_plan_dirs <- function(plan_constants) {
  # Base directories
  data_raw <- here::here("data-raw")
  plans_dir <- fs::path(data_raw, "plans")
  plan_dir <- fs::path(plans_dir, plan_constants$plan)

  # Return named list
  list(
    # Top-level folders
    extract_data = fs::path(data_raw, "extract_data"),

    # Plan-specific folders
    xddir = fs::path(plan_dir, "extracted_data"),
    plan_xdfile = fs::path(
      plan_dir,
      "extracted_data",
      plan_constants$xd_filename
    ),
    work = fs::path(plan_dir, "work"),
    staged = fs::path(plan_dir, "staged"),
    prep_code = fs::path(data_raw, "prepare_data", plan_constants$plan)
  )
}
