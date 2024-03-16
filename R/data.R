#' Pub.H-2010 Headcount-Weighted Mortality Rates
#'
#' Raw data from SOA's Pub.H-2010 Headcount-Weighted Mortality Rates.
#'
#' @format ## `pub2010hc_mortality_rates`
#' A tibble with 3,708 rows and 4 columns:
#' \describe{
#'   \item{employee_type}{"teacher", "safety" or "general"}
#'   \item{beneficiary_type}{"employee", "healthy_retiree", "disabled_retiree",
#'   or "contingent_survivor"}
#'   \item{age}{integer generally ranging from 18 to 120}
#'   \item{rate}{mortality rate as decimal number}
#' }
#' @source
#' <https://www.soa.org/49347a/globalassets/assets/files/resources/research-report/2019/pub-2010-headcount-mort-rates.xlsx>
"pub2010hc_mortality_rates"



#' Mortality Improvement Scale MP-2018
#'
#' Raw data from Scale MP-2018, the latest iteration of the pension mortality
#' improvement scales developed annually by the Retirement Plans Experience
#' Committee (RPEC) of the Society of Actuaries (SOA).
#'
#' The source spreadsheet data is in wide format. This data file has been
#' converted to a long format but otherwise is the same as the source data.
#'
#' @format ## `mp2018`
#' A tibble with 16,968 rows and 4 columns:
#' \describe{
#'   \item{gender}{'male' or 'female'}
#'   \item{year}{integer ranging from 1951 to 2034}
#'   \item{age}{integer ranging from 20 to 120}
#'   \item{mp}{mortality improvement rate as decimal number; can be negative}
#' }
#' @source
#' <https://www.soa.org/493456/globalassets/assets/files/resources/experience-studies/2018/mortality-improvement-scale-mp-2018-rates.xlsx>
"mp2018"
