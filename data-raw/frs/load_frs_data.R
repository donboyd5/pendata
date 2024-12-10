load_frs_data <- function() {
  # During package installation, system.file won't work
  # because the package isn't installed yet
  data_path <- system.file("data", "frs.rda", package = "pendata")

  if (data_path == "") {
    # Fallback for installation time
    data_path <- file.path("data", "frs.rda")
  }

  load(data_path)
}
