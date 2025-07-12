# setup.R

source(here::here("data-raw", "R", "libraries.R"))
source(here::here("data-raw", "R", "constants.R"))
source(here::here("data-raw", "R", "folders_function.R"))
source(here::here("data-raw", "R", "functions.R"))
source(here::here("data-raw", "R", "functions_data.R"))

PLAN_CONSTANTS <- jsonlite::fromJSON(here::here("data-raw", "plan_config.json"))
