
frs_constants <- list()


# regular_total_active_member_ <- 537128
# special_total_active_member_ <- 72925
# admin_total_active_member_ <- 104
# eco_eso_judges_total_active_member_ <- 2075
# senior_management_total_active_member_ <- 7610

total_actives <- read_csv("
class, total_actives
regular, 537128
special, 72925
admin, 104
eco_eso_judges, 2075
senior_management, 7610")

frs_constants <- within(frs_constants,{
  start_year <- 2022
  yos_max <- 70
  total_actives <- total_actives
})

# put the list of constants in alpha order by name
frs_constants <- frs_constants[order(names(frs_constants))]

# frs_constants




