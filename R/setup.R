# setup.R

source(here::here("R", "libraries.R"))
source(here::here("R", "constants.R"))
source(here::here("R", "folders_function.R"))
source(here::here("R", "functions.R"))

PLAN_CONSTANTS <- jsonlite::fromJSON(here::here("plan_config.json"))
