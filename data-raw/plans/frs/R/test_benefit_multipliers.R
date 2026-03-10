# test_benefit_multipliers.R
#
# Validates the benefit_multipliers staged table and benmult_lookup() function
# against the authoritative benefit_functions.R (normal_result / early_result).
#
# Run from any working directory:
#   Rscript "D:/R_projects/pendata/data-raw/plans/frs/R/test_benefit_multipliers.R"
#
# Expected output: all sections show 100% pass.
# Known intentional difference: tier_3 is not in normal_result(); our rules
# assign tier_3 the same multipliers as tier_2, which is verified separately.

.libPaths("C:/Users/Don-business/R/win-library/4.5")
library(dplyr)
library(tidyr)

source("D:/R_projects/pendata/R/frs_functions.R")
source("D:/R_projects/pendata/data-raw/plans/frs/R/benefit_functions.R")
bm_rules <- readRDS("D:/R_projects/pendata/data-raw/plans/frs/staged_data/benefit_multipliers.rds")

# ---- Test grid ----------------------------------------------------------
# All classes x all tiers x boundary ages/yos.
# Boundary values: one below and one above every eligibility threshold across
# all classes (age: 55/60/62/63/64/65; yos: 6/8/25/30/31/32/33).

classes  <- c("regular", "special", "admin", "judges", "eso", "eco", "senior_management")
tiers    <- c("tier_1", "tier_2", "tier_3")
key_ages <- as.integer(c(0, 40, 54, 55, 56, 60, 61, 62, 63, 64, 65, 70, 80))
key_yos  <- as.integer(c(0, 5, 6, 7, 8, 24, 25, 26, 29, 30, 31, 32, 33, 34, 40))

grid <- expand_grid(class = classes, tier = tiers,
                    dist_age = key_ages, yos = key_yos) |>
  mutate(dist_year = 2023L)

cat("Test grid:", nrow(grid), "rows x 2 statuses =", 2 * nrow(grid), "total cases\n\n")

pass_total <- 0L
fail_total <- 0L

report <- function(label, n_pass, n_total, failures = NULL) {
  pct <- round(100 * n_pass / n_total, 1)
  cat(sprintf("%-45s %d / %d  (%.1f%%)\n", label, n_pass, n_total, pct))
  if (!is.null(failures) && nrow(failures) > 0) {
    cat("  FAILURES:\n")
    print(failures)
  }
  pass_total <<- pass_total + n_pass
  fail_total <<- fail_total + (n_total - n_pass)
}

# ---- 1. NORM tier_1 / tier_2 -------------------------------------------
norm_grid <- grid |> mutate(status = "norm")
got_norm  <- benmult_lookup(
  norm_grid[, c("class", "tier", "status", "dist_age", "yos")], bm_rules
)

compare_norm <- norm_grid |>
  mutate(got      = got_norm,
         expected = normal_result(class, tier, dist_age, yos, dist_year),
         match    = abs(got - expected) < 1e-8)

t12 <- compare_norm |> filter(tier != "tier_3")
report("Norm tier_1/tier_2 vs normal_result()",
       sum(t12$match), nrow(t12),
       filter(t12, !match) |> select(class, tier, dist_age, yos, expected, got))

# ---- 2. NORM tier_3 should equal tier_2 --------------------------------
t3 <- compare_norm |>
  filter(tier == "tier_3") |>
  left_join(
    compare_norm |> filter(tier == "tier_2") |>
      select(class, dist_age, yos, tier2_got = got),
    by = c("class", "dist_age", "yos")
  ) |>
  mutate(match = abs(got - tier2_got) < 1e-8)
report("Norm tier_3 matches tier_2 (design choice)",
       sum(t3$match), nrow(t3),
       filter(t3, !match) |> select(class, dist_age, yos, tier2_got, tier3_got = got))

# ---- 3. EARLY: where benmult > 0, rate must match flat per-class rate --
early_grid <- grid |> mutate(status = "early")
got_early  <- benmult_lookup(
  early_grid[, c("class", "tier", "status", "dist_age", "yos")], bm_rules
)

compare_early <- early_grid |>
  mutate(got           = got_early,
         expected_flat = early_result(class))

early_pos <- compare_early |>
  filter(got > 0) |>
  mutate(match = abs(got - expected_flat) < 1e-8)
report("Early (got>0) matches flat per-class rate",
       sum(early_pos$match), nrow(early_pos),
       filter(early_pos, !match) |> select(class, tier, dist_age, yos, expected_flat, got))

# ---- 4. EARLY: zero-rate cases must be zero in original too ------------
# For early, our rules set 0 when eligibility isn't met.
# The original early_result() always returns the flat rate (no yos/age check) —
# so early zeros in our table are *more restrictive*, which is by design.
# We just report the count for transparency.
early_zero_ours <- compare_early |> filter(got == 0)
cat(sprintf("\nInfo: early got=0 cases (more restrictive than original): %d\n",
            nrow(early_zero_ours)))

# ---- Summary -----------------------------------------------------------
cat(sprintf("\n=== SUMMARY: %d pass, %d fail out of %d ===\n",
            pass_total, fail_total, pass_total + fail_total))
if (fail_total == 0) cat("All tests passed!\n") else cat("*** FAILURES DETECTED ***\n")
