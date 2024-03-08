#' Extend a mortality improvement table.
#'
#' Extend a mortality improvement table with more ages and years, index the
#' cumulative mp rate to a baseyear.
#'
#' @param mptable Numeric. Mortality improvement table to be extended. Must
#'   contain columns age, gender, mp, and year.
#' @param startage Numeric. Desired starting age for mp dataframe.
#' @param endyear Numeric. Desired end year for mp dataframe.
#' @param baseyear Numeric. Year mortality rate should be indexed to.
#' @return Dataframe. Extended mortality improvement table.
#'
#' @examples
#' library(pendata)
#' data(package="pendata")
#' xmp <- mp2018 |>
#'   extend_mp(startage=18, endyear=2154, baseyear=2010)
#'
#' @export
extend_mp <- function(mptable, startage=18, endyear=2154, baseyear=2010){
  # will extend any mp table with additional ages or years
  # I use .data$ below so that when running CMD CHECK on the package, it does
  # not think the variables age, gender, ... in mptable could be global
  # variables and issue a note. I'm trying to minimize CMD CHECK exceptions.
  #
  mptablex <- mptable |>
    arrange(.data$gender, .data$year, .data$age) |>
    reframe(add_younger(pick(everything())),
            .by=c(.data$gender, .data$year)) |>
    reframe(add_years(pick(everything()), endyear),
            .by=c(.data$gender, .data$age)) |>
    arrange(.data$gender, .data$age, .data$year) |>
    # cumulative improvement from earliest year to latest
    mutate(mpc=cumprod(1 - .data$mp), .by=c(.data$gender, .data$age)) |>
    mutate(mpcadj=.data$mpc / .data$mpc[.data$year==baseyear],
           .by=c(.data$gender, .data$age)) # rebase

  mptablex
}

# tmp <- mp2018 |>
#   extend_mp(startage=18, endyear=2154, baseyear=2010)


#' Add rows with younger ages to a mortality improvement dataframe.
#'
#' This function makes copies of the youngest age in a mortality improvement
#' dataframe to create identical rows but with younger ages. The dataframe can
#' be grouped and rows added to each group.
#'
#' @param df Dataframe. First column is age; rows have mortality improvement.
#' @param startage Numeric. Desired starting age for mp dataframe.
#' @return Dataframe. Original dataframe with additional rows prepended.
#'
#' @examples
#' library(pendata)
#' data(package="pendata")
#' mp2018 |>
#'   add_younger(startage=18)
#'
#' @export
add_younger <- function(df, startage=18){

  current_startage <- min(df$age)
  n_newrows <- current_startage - startage
  new_ages <- startage:(current_startage - 1)

  first_row <- df |>
    slice_head(n = 1)

  new_rows <- first_row  |>
    slice(rep(1:n(), each = n_newrows)) |>
    mutate(age=new_ages)

  bind_rows(new_rows, df) # return the new, longer data frame
}


#' Add rows with additional years to a mortality improvement dataframe.
#'
#' Repeat the final row in a dataframe (or dataframe group), with the year
#' increased by 1 with each new row.
#'
#' @param df Dataframe. First column is age; rows have mortality improvement.
#' @param endyear Numeric. New last year.
#' @return Dataframe. Extended dataframe with additional rows appended.
#'
#' @examples
#' library(pendata)
#' data(package="pendata")
#' extended <- mp2018 |>
#'   add_years(endyear=2040)
#'
#' @export
add_years <- function(df, endyear){

  current_endyear <- max(df$year)
  n_newrows <- endyear - current_endyear
  new_years <- (current_endyear + 1):endyear

  last_row <- df |>
    slice_tail(n = 1)

  new_rows <- last_row  |>
    slice(rep(1:n(), each = n_newrows)) |>
    mutate(year = new_years)

  bind_rows(df, new_rows)
}
