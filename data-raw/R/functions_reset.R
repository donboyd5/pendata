reset_all <- function(plan, delete = FALSE) {
  data <- here::here("data")
  plan_dir <- here::here("data-raw", "plans", plan)
  work <- fs::path(plan_dir, "work")
  staged <- fs::path(plan_dir, "staged")

  # Data file path correction
  if (!fs::dir_exists(data)) {
    message(sprintf("Data directory does not exist: %s", data))
    data_files <- character(0)
  } else {
    candidate <- fs::path(data, paste0(plan, ".rda"))
    if (fs::file_exists(candidate)) {
      data_files <- candidate
    } else {
      data_files <- character(0)
    }
  }

  if (!fs::dir_exists(work)) {
    message(sprintf("Work directory does not exist: %s", work))
    work_files <- character(0)
  } else {
    work_rds_files <- fs::dir_ls(path = work, glob = "*.rds")
    work_csv_files <- fs::dir_ls(path = work, glob = "*.csv")
    work_files <- c(work_rds_files, work_csv_files)
  }

  if (!fs::dir_exists(staged)) {
    message(sprintf("Staged directory does not exist: %s", staged))
    staged_files <- character(0)
  } else {
    staged_files <- fs::dir_ls(path = staged, glob = "*.rds")
  }

  files <- c(data_files, work_files, staged_files)

  if (length(files) == 0) {
    message("No files found to delete.")
  } else if (delete) {
    purrr::walk(files, function(file) {
      if (fs::file_exists(file)) {
        fs::file_delete(file)
        message(sprintf("Deleted: %s", file))
      }
    })
  } else {
    message(
      "Files available to delete (call reset_all() with 'delete = TRUE'):"
    )
    purrr::walk(files, message)
  }

  invisible(NULL)
}

# Example usage
# reset_all("frs", delete = FALSE)
# reset_all("frs")
