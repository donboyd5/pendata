#' Look up benefit multiplier using priority-ordered rules
#'
#' Applies the `benefit_multipliers` rule table to a data frame of member
#' records.  Rules are matched in ascending priority order (priority 1 is
#' checked first); the first matching rule's `benmult` is returned.
#'
#' Matching conditions (all must hold):
#' \itemize{
#'   \item `yos >= min_yos`
#'   \item `dist_age >= min_age` (ignored when `min_age` is `NA`)
#'   \item `dist_age < max_age`  (ignored when `max_age` is `NA`)
#' }
#'
#' @param data A data frame with columns `class`, `tier`, `status`,
#'   `dist_age`, and `yos`.  `status` should be `"norm"` or `"early"`.
#' @param benefit_multipliers The rule table (typically
#'   `frs$benefit_multipliers` from pendata).  Must have columns `class`,
#'   `tier`, `status`, `priority`, `min_yos`, `min_age`, `max_age`,
#'   `benmult`.
#'
#' @return A numeric vector of length `nrow(data)` with the benefit
#'   multiplier for each row (0 where no rule matches).
#'
#' @examples
#' \dontrun{
#' params$ben_mult_lookup <- tidyr::expand_grid(
#'   class = unique(params$class_names_no_drop_frs_),
#'   tier  = c("tier_1", "tier_2", "tier_3"),
#'   status = c("norm", "early"),
#'   dist_age = params$age_range_,
#'   yos      = params$yos_range_
#' ) |>
#'   dplyr::mutate(
#'     benmult = benmult_lookup(
#'       dplyr::pick(class, tier, status, dist_age, yos),
#'       frs$benefit_multipliers
#'     )
#'   )
#' }
#'
#' @export
benmult_lookup <- function(data, benefit_multipliers) {
  # Fill NA bounds so inequality joins work cleanly:
  #   min_age NA  -> 0    (no lower age constraint)
  #   max_age NA  -> Inf  (no upper age constraint)
  bm <- benefit_multipliers |>
    dplyr::mutate(
      min_age = dplyr::coalesce(as.numeric(min_age), 0),
      max_age = dplyr::coalesce(as.numeric(max_age), Inf)
    )

  data |>
    dplyr::mutate(.id__ = dplyr::row_number()) |>
    dplyr::left_join(
      bm,
      dplyr::join_by(
        class    == class,
        tier     == tier,
        status   == status,
        yos      >= min_yos,
        dist_age >= min_age,
        dist_age <  max_age
      )
    ) |>
    dplyr::mutate(benmult = tidyr::replace_na(benmult, 0)) |>
    dplyr::slice_min(priority, with_ties = FALSE, by = .id__) |>
    dplyr::pull(benmult)
}
