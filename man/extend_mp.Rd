% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extend_mp.R
\name{extend_mp}
\alias{extend_mp}
\title{Extend a mortality improvement table.}
\usage{
extend_mp(mptable, startage = 18, endyear = 2154, baseyear = 2010)
}
\arguments{
\item{mptable}{Numeric. Mortality improvement table to be extended. Must
contain columns age, gender, mp, and year.}

\item{startage}{Numeric. Desired starting age for mp dataframe.}

\item{endyear}{Numeric. Desired end year for mp dataframe.}

\item{baseyear}{Numeric. Year mortality rate should be indexed to.}
}
\value{
Dataframe. Extended mortality improvement table.
}
\description{
Extend a mortality improvement table with more ages and years, index the
cumulative mp rate to a baseyear.
}
\examples{
library(pendata)
data(package="pendata")
xmp <- mp2018 |>
  extend_mp(startage=18, endyear=2154, baseyear=2010)

}
