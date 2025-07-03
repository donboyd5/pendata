# packages we'll usually want to use regardless of subproject

libs <- function() {
  library(rlang)
  library(tidyverse)
  tprint <- 75 # default tibble print
  options(tibble.print_max = tprint, tibble.print_min = tprint) # show up to tprint rows

  # tools
  library(fs)
  library(stringr)
  library(vroom)
  library(readxl)
  library(openxlsx2) # for writing xlsx files
  library(lubridate)
  library(RColorBrewer)
  library(RcppRoll)
  library(testthat)
  # library(fredr)
  # library(tidycensus)

  # boyd libraries
  # library(btools)
  # library(bdata)
  # library(bggtools)

  # graphics
  library(scales)
  # library(ggbeeswarm)
  library(patchwork)
  library(gridExtra)
  library(ggrepel)
  library(ggbreak)

  # tables
  library(formattable)
  library(knitr)
  library(kableExtra)
  library(DT)
  library(gt)
  library(gtExtras)
  library(janitor)
  library(skimr)
  library(vtable)
}

suppressMessages(libs())

rm(libs)
