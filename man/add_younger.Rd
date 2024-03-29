% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extend_mp.R
\name{add_younger}
\alias{add_younger}
\title{Add rows with younger ages to a mortality improvement dataframe.}
\usage{
add_younger(df, startage = 18)
}
\arguments{
\item{df}{Dataframe. First column is age; rows have mortality improvement.}

\item{startage}{Numeric. Desired starting age for mp dataframe.}
}
\value{
Dataframe. Original dataframe with additional rows prepended.
}
\description{
This function makes copies of the youngest age in a mortality improvement
dataframe to create identical rows but with younger ages. The dataframe can
be grouped and rows added to each group.
}
\examples{
library(pendata)
data(package="pendata")
mp2018 |>
  add_younger(startage=18)

}
