% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extend_mp.R
\name{extend_mp}
\alias{extend_mp}
\title{Extend a mortality improvement table.}
\usage{
extend_mp(mptable, startage = 18, endyear = 2154, baseyear = 2010)
}
\arguments{
\item{mptable}{Numeric. Price of a single fruit.}

\item{startage}{Numeric. Number of fruits.}
}
\value{
Numeric. Total price.
}
\description{
Extend a mortality improvement table with more ages and years, index the
cumulative mp rate to a baseyear.
}
\examples{
library(tidyverse)
library(pendata)
data(package="pendata")
xmp <- mp2018 |>
  extend_mp(startage=18, endyear=2154, baseyear=2010)

}