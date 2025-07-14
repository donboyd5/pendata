reset_all <- function(plan, delete = FALSE) {
  source(here::here("data-raw", "R", "functions_folders.R"))
  DIRS <- set_plan_dirs(plan)

  data <- DIRS$data
  plan_dir <- DIRS$plan_dir
  work <- DIRS$work
  staged <- DIRS$staged

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
      paste0(
        'Files below are available to delete. To delete, call `reset_all("',
        plan,
        '", delete = TRUE).`\n'
      )
    )
    purrr::walk(files, message)
  }

  invisible(NULL)
}

# Example usage
# reset_all("frs")
# reset_all("frs", delete = TRUE)
