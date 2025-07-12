# before running, close any externally open files (e.g., Excel) that are in project folders

# Clear existing package if loaded
if ("package:pendata" %in% search()) {
  detach("package:pendata", unload = TRUE, force = TRUE)
}

# Remove installed package
try(remove.packages("pendata"), silent = TRUE)

# Clear objects from memory
rm(list = ls(all.names = TRUE)) # Clears all objects
gc() # Triggers garbage collection

# Rebuild and install
devtools::document()
devtools::install()

# Load the fresh package
library(pendata)
packageVersion("pendata")

plan <- pendata::frs
