# get standard data from the Excel file

get_item <- function(s, info) {
  value <- info$value[info$item == s]
}

item_exists <- function(s, info) {
  any(info$item == s & !is.na(info$value))
}

get_limits <- function(info) {
  limits <- NULL
  if (
    item_exists("start_col", info) &&
      item_exists("end_col", info) &&
      item_exists("start_row", info)
  ) {
    start_col <- cellranger::letter_to_num(get_item("start_col", info))
    end_col <- cellranger::letter_to_num(get_item("end_col", info))
    start_row <- get_item("start_row", info) |> as.numeric()
    # Create cell_limits object
    limits <- cell_limits(
      ul = c(start_row, start_col),
      lr = c(NA, end_col) # NA means go to bottom of the sheet
    )
  }
  limits
}

get_data <- function(sheet, path) {
  info <- suppressMessages(read_excel(
    path,
    sheet = sheet,
    range = cell_cols("A:B"),
    col_names = c("item", "value")
  ))
  info <- bind_rows(tibble(item = "sheet", value = sheet), info)

  limits <- get_limits(info)

  data <- NULL
  # only get data if we have a valid limits object
  if (!is.null(limits)) {
    data <- suppressMessages(read_excel(
      path,
      sheet = sheet,
      range = limits,
      col_types = "text"
    ))
  }

  return(list(info = info, data = data))
}
