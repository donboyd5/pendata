#' Extend a mortality improvement table.
#'
#' Extend a mortality improvement table with more ages and years, index the
#' cumulative mp rate to a baseyear.
#'
#' @param mptable Numeric. Price of a single fruit.
#' @param startage Numeric. Number of fruits.
#' @param endyear
#' @param baseyear
#' @return Numeric. Total price.
#'
#' @examples
#' library(tidyverse)
#' library(pendata)
#' data(package="pendata")
#' xmp <- mp2018 |>
#'   extend_mp(startage=18, endyear=2154, baseyear=2010)
#'
#' @export
extend_mp <- function(mptable, startage=18, endyear=2154, baseyear=2010){
  # will extend any mp table with additional ages or years
  mptablex <- mptable |>
    arrange(gender, year, age) |>
    reframe(add_younger(pick(everything())), .by=c(gender, year)) |>
    reframe(add_years(pick(everything()), endyear), .by=c(gender, age)) |>
    arrange(gender, age, year) |>
    mutate(mpc=cumprod(1 - mp), .by=c(gender, age)) |> # cumulative improvement from earliest year to latest
    mutate(mpcadj=mpc / mpc[year==baseyear], .by=c(gender, age)) # rebase

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
#' @param df dataframe where the fist column is age and the rows have mortality
#'   improvement.
#' @return longer dataframe that has additional rows prepended.
#'
#' @examples
#' library(tidyverse)
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
#' @param df dataframe where the fist column is age and the rows have mortality
#'   improvement.
#' @param endyear integer year that will be the new last year
#' @return longer dataframe that has additional rows appended.
#'
#' @examples
#' library(tidyverse)
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
