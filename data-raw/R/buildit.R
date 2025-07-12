# close any externally open files (e.g., Excel) that are in project folders
detach(package:pendata)
remove.packages("pendata")
devtools::document()
# devtools::build() # not needed when doing devtools::install()
devtools::install()
library(pendata)
plan <- pendata::frs
