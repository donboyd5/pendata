% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extend_mp.R
\name{add_years}
\alias{add_years}
\title{Add rows with additional years to a mortality improvement dataframe.}
\usage{
add_years(df, endyear)
}
\arguments{
\item{df}{Dataframe. First column is age; rows have mortality improvement.}

\item{endyear}{Numeric. New last year.}
}
\value{
Dataframe. Extended dataframe with additional rows appended.
}
\description{
Repeat the final row in a dataframe (or dataframe group), with the year
increased by 1 with each new row.
}
\examples{
library(pendata)
data(package="pendata")
extended <- mp2018 |>
  add_years(endyear=2040)

}
