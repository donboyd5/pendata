# setup.R

source(here::here("data-raw", "R", "libraries.R"))
source(here::here("data-raw", "R", "constants.R"))
source(here::here("data-raw", "R", "function_folders.R"))
source(here::here("data-raw", "R", "functions.R"))

PLAN_CONSTANTS <- jsonlite::fromJSON(here::here("data-raw", "plan_config.json"))
