
frs_constants <- list()

frs_constants <- within(frs_constants,{
  start_year <- 2022
  yos_max <- 70
})

# put the list of constants in alpha order by name
frs_constants <- frs_constants[order(names(frs_constants))]

# frs_constants
