
# NOTES:

#   1) To force execution of all calculations, even if .qmd files have not changed
#      since last quarto render, edit the relevant _quarto.yml file in the
#      folder that is going to be rendered to make sure the
#      execution: freeze: parameter is set to false.

#   2) To force re-downloading or initial downloading of SOA files, do #1 above
#      AND make sure download="true" in the quarto_render() call below. To
#      prevent downloading, set download="false"


# setup -------------------------------------------------------------------

rm(list = ls())

draw <- here::here("data-raw")
dstd <- fs::path(draw, "standard")
dfrs <- fs::path(draw, "systems", "frs")

source(fs::path(draw, "libraries.r"))


# get standard actuarial tables and data for individual systems ----
quarto_render(dstd, execute_params=list(download="false")) # standard actuarial information
quarto_render(dfrs) # Florida Retirement System


# Build and install the updated package ----

(package_root <- usethis::proj_get())
devtools::document(package_root)
devtools::check(package_root) # not essential to check for CRAN requirements but good practice
devtools::build(package_root)
devtools::install(package_root)


# look at newly installed package ----
library(pendata)
# data(package="pendata")
data(frs)
names(frs)
