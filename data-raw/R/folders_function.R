# set_plan_dirs <- function(PLAN_CONSTANTS) {
#   plans <- here::here("data-raw", "plans") # ALL data for specific plans is here, other than final package data
#   list(
#     # top-level folders for all plans
#     extract_data = here::here("data-raw", "extract_data"), # generic quarto project for extracting data
#     prepare_data = here::here("data-raw", "prepare_data"), # holds plan-specific folders for preparing extracted data

#     # plan-specific folders
#     plandir = fs::path(plans, PLAN_CONSTANTS$plan),
#     xddir = fs::path(plans, PLAN_CONSTANTS$plan, "extracted_data"),
#     plan_xdfile = fs::path(
#       plans,
#       PLAN_CONSTANTS$plan,
#       "extracted_data",
#       PLAN_CONSTANTS$xd_filename
#     ),
#     work = fs::path(plans, PLAN_CONSTANTS$plan, "work"),
#     staged = fs::path(plans, PLAN_CONSTANTS$plan, "staged"),
#     prep_code = fs::path(
#       here::here("data-raw", "prepare_data"),
#       PLAN_CONSTANTS$plan
#     )
#   )
# }

set_plan_dirs <- function(plan_constants) {
  # Base directories
  data_raw <- here::here("data-raw")
  plans_dir <- fs::path(data_raw, "plans")
  plan_dir <- fs::path(plans_dir, plan_constants$plan)

  # Return named list
  list(
    # Top-level folders
    extract_data = fs::path(data_raw, "extract_data"),
    prepare_data = fs::path(data_raw, "prepare_data"),

    # Plan-specific folders
    plandir = plan_dir,
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
