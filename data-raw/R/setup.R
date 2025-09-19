# setup.R

# setup MUST know the global variable GROOT (where .git/index is)
source(fs::path(GROOT, "data-raw", "R", "libraries.R"))
source(fs::path(GROOT, "data-raw", "R", "constants.R"))
source(fs::path(GROOT, "data-raw", "R", "functions.R"))
source(fs::path(GROOT, "data-raw", "R", "functions_get_excel_data.R"))
source(fs::path(GROOT, "data-raw", "R", "functions_folders.R"))

PLAN_CONSTANTS <- jsonlite::fromJSON(fs::path(
  GROOT,
  "data-raw",
  "plan_config.json"
))
DIRS <- set_plan_dirs(PLAN_CONSTANTS$plan)
