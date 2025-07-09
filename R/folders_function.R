set_plan_dirs <- function(PLAN_CONSTANTS) {
  plans <- here::here("plans") # ALL data for specific plans is here, other than final package data
  list(
    # top-level folders for all plans
    extract_data = here::here("extract_data"), # generic quarto project for extracting data
    prepare_data = here::here("prepare_data"), # holds plan-specific folders for preparing extracted data

    # plan-specific folders
    plandir = fs::path(plans, PLAN_CONSTANTS$plan),
    xddir = fs::path(plans, PLAN_CONSTANTS$plan, "extracted_data"),
    plan_xdfile = fs::path(
      plans,
      PLAN_CONSTANTS$plan,
      "extracted_data",
      PLAN_CONSTANTS$xd_filename
    ),
    work = fs::path(plans, PLAN_CONSTANTS$plan, "work"),
    staged = fs::path(plans, PLAN_CONSTANTS$plan, "staged"),
    prep_code = fs::path(here::here("prepare_data"), PLAN_CONSTANTS$plan)
  )
}
