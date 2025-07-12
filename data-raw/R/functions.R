flip <- function(
  data, # data frame to be flipped
  rowvar, # name to use as prefix for row identifiers -- string -- e.g., "age"
  colvar, # name to use as prefix for column identifiers -- string -- e.g., "yos"
  rowlb = NULL, # lower bounds for the row -- numeric vector -- e.g., 10 if the row label is "10-19"
  rowub = NULL, # upper bounds for the row -- numeric vector
  rowlabels = NULL, # string vector, if missing will use 1st column
  collb = NULL, # lower bounds for the columns in the raw data -- numeric vector -- e.g., 20 if column label is "20-24"
  colub = NULL, # upper bounds for the column -- numeric vector
  collabels = NULL # if NULL will use column names
) {
  # flip assumes a data frame where first column is a label and other columns are (or will be converted to) numeric
  if (is.null(rowlabels)) {
    rowlabels <- data |> pull(1)
  }
  if (is.null(collabels)) {
    collabels <- names(data)[-1]
  }
  coltbl <- tibble(collabel = collabels, collb, colub)

  datalong <- data |>
    select(-1) |>
    mutate(rowlabel = rowlabels, rowlb = rowlb, rowub = rowub) |>
    pivot_longer(
      cols = -c(rowlabel, rowlb, rowub),
      names_to = "collabel"
    ) |>
    left_join(coltbl, by = join_by(collabel)) |>
    relocate(value, .after = colub) |>
    mutate(value = replace_na(as.numeric(value), 0)) |>
    rename_with(
      .fn = \(x) str_replace(x, "row", paste0(rowvar, "_")),
      .cols = starts_with("row")
    ) |>
    rename_with(
      .fn = \(x) str_replace(x, "col", paste0(colvar, "_")),
      .cols = starts_with("col")
    )
  return(datalong)
}

flip_stack <- function(
  sheet_names,
  rawdata,
  rowvar,
  colvar,
  rowlb,
  rowub,
  collb,
  colub
) {
  # get data sheets from rawdata, flip and stack, and return a long tibble

  # create data_list -- each sheet is an element
  data_list <- sheet_names |>
    purrr::map(\(x) pluck(rawdata, x, "data")) |>
    setNames(sheet_names)

  # create tbl_list where each sheet has been flipped
  tbl_list <- purrr::map(
    data_list,
    flip,
    rowvar,
    colvar,
    rowlb,
    rowub,
    rowlabels = NULL,
    collb,
    colub,
    collabels = NULL
  )

  # bind the sheets into a long tibble
  long_tbl <- list_rbind(tbl_list, names_to = "src") |>
    separate(src, into = c("variable", "group"), sep = "_", extra = "merge")

  return(long_tbl)
}

# flip(
#   data,
#   rowvar = "age",
#   colvar = "yos",
#   rowlb = agelb,
#   rowub = ageub,
#   collb = yoslb,
#   colub = yosub
# )

all_tests_passed <- function(test_results) {
  # inspect a list of testthat results to see if all are passed
  test_results |>
    as_tibble() |>
    pull(passed) |>
    all()
}
