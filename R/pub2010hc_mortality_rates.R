#' Pub.H-2010 Headcount-Weighted Mortality Rates
#'
#' A dataset containing mortality rates from the Society of Actuaries' Public Retirement Plans Mortality Study
#' published in 2019. The rates are based on public pension plan experience from 2008-2013, centered around 2010.
#'
#' @format A tibble with 1,878 rows and 5 variables:
#' \describe{
#'   \item{employee_type}{Type of public sector worker: "general", "safety", or "teacher"}
#'   \item{beneficiary_type}{Category of benefit recipient:
#'     \itemize{
#'       \item employee: Active employee
#'       \item healthy_retiree: Retired, not disabled
#'       \item disabled_retiree: Retired due to disability
#'       \item contingent_survivor: Beneficiary after death of primary recipient
#'     }
#'   }
#'   \item{gender}{Sex of the individual: "male" or "female"}
#'   \item{age}{Age of person in years (numeric)}
#'   \item{rate}{Annual mortality rate as a decimal (e.g., 0.01 = 1% probability)}
#' }
#'
#' @source Society of Actuaries (2019). Public Pension Mortality Study (Pub-2010)
#' @references
#' Society of Actuaries (2019). Public Pension Mortality Study.
#' \url{https://www.soa.org/resources/research-reports/2019/pub-2010-retirement-plans/}
#'
#' @examples
#' # View first few rows
#' head(pub2010hc_mortality_rates)
#'
#' # Get average mortality rate for male teachers
#' pub2010hc_mortality_rates |>
#'   dplyr::filter(
#'     employee_type == "teacher",
#'     gender == "male"
#'   ) |>
#'   dplyr::summarise(mean_rate = mean(rate))
"pub2010hc_mortality_rates"
