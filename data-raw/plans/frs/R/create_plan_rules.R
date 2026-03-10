# create_plan_rules.R
# Creates new plan rule staged data files for FRS:
#   - class_groups.rds        (7 rows: class -> class_group)
#   - tier_map.rds            (3 rows: tier_id, entry_year range)
#   - status_paths.rds        (25 rows: tier x class_group x status -> eligibility)
#   - status_priority.rds     (4 rows: status priority order)
#   - benefit_multipliers.rds (compact priority-ordered rules -> benmult)
#
# Sources:
#   - class_groups/tier_map/status_paths/status_priority: Gang's plan_rule_tables.xlsx
#   - benefit_multipliers: authoritative source is benefit_functions.R normal_result()
#     and early_result(), cross-checked against FRS AV2022.
#     Tier 3 uses same multipliers as Tier 2 (same plan provisions, new entry_year range).
#
# Format for benefit_multipliers:
#   Priority-ordered rules (priority 1 = first checked, first match wins).
#   Conditions min_yos / min_age / max_age: NA means no constraint.
#   max_age is an EXCLUSIVE upper bound (i.e., dist_age < max_age).
#   Status "early" rows store the base benmult; early reduction factor applied separately.

.libPaths("C:/Users/Don-business/R/win-library/4.5")
library(tibble)
library(dplyr)

staged <- "D:/R_projects/pendata/data-raw/plans/frs/staged_data"

# ---------------------------------------------------------------------------
# 1. class_groups
# ---------------------------------------------------------------------------
class_groups <- tribble(
  ~class,             ~class_group,
  "regular",          "GEN",
  "special",          "SPEC",
  "admin",            "SPEC",
  "eco",              "GEN",
  "eso",              "GEN",
  "judges",           "GEN",
  "senior_management","GEN"
)

saveRDS(class_groups, file.path(staged, "class_groups.rds"))
cat("Saved class_groups.rds:", nrow(class_groups), "rows\n")

# ---------------------------------------------------------------------------
# 2. tier_map
# ---------------------------------------------------------------------------
tier_map <- tribble(
  ~tier_id, ~entry_year_min, ~entry_year_max,
  "tier_1",  0L,              2010L,
  "tier_2",  2011L,           2023L,
  "tier_3",  2024L,           9999L
)

saveRDS(tier_map, file.path(staged, "tier_map.rds"))
cat("Saved tier_map.rds:", nrow(tier_map), "rows\n")

# ---------------------------------------------------------------------------
# 3. status_paths
# Each row is one eligibility path: tier x class_group x status.
# Multiple paths per combination (path_id) means OR logic.
# A member satisfies a status if they meet ANY path's (min_yos AND min_age).
# ---------------------------------------------------------------------------
status_paths <- tribble(
  ~tier_id, ~class_group, ~status,  ~path_id, ~min_yos, ~min_age,
  # Tier 1 SPEC (special, admin)
  "tier_1", "SPEC",       "norm",    1L,        25L,       0L,
  "tier_1", "SPEC",       "norm",    2L,         6L,      55L,
  "tier_1", "SPEC",       "norm",    3L,        25L,      52L,
  "tier_1", "SPEC",       "early",   1L,         6L,      53L,
  "tier_1", "SPEC",       "vested",  1L,         6L,       0L,
  # Tier 1 GEN (regular, eco, eso, judges, senior_management)
  "tier_1", "GEN",        "norm",    1L,        30L,       0L,
  "tier_1", "GEN",        "norm",    2L,         6L,      62L,
  "tier_1", "GEN",        "early",   1L,         6L,      58L,
  "tier_1", "GEN",        "vested",  1L,         6L,       0L,
  # Tier 2 SPEC
  "tier_2", "SPEC",       "norm",    1L,        30L,       0L,
  "tier_2", "SPEC",       "norm",    2L,         8L,      60L,
  "tier_2", "SPEC",       "early",   1L,         8L,      56L,
  "tier_2", "SPEC",       "vested",  1L,         8L,       0L,
  # Tier 2 GEN
  "tier_2", "GEN",        "norm",    1L,        33L,       0L,
  "tier_2", "GEN",        "norm",    2L,         8L,      65L,
  "tier_2", "GEN",        "early",   1L,         8L,      61L,
  "tier_2", "GEN",        "vested",  1L,         8L,       0L,
  # Tier 3 SPEC (same eligibility rules as tier_2, new entry_year range)
  "tier_3", "SPEC",       "norm",    1L,        30L,       0L,
  "tier_3", "SPEC",       "norm",    2L,         8L,      60L,
  "tier_3", "SPEC",       "early",   1L,         8L,      56L,
  "tier_3", "SPEC",       "vested",  1L,         8L,       0L,
  # Tier 3 GEN
  "tier_3", "GEN",        "norm",    1L,        33L,       0L,
  "tier_3", "GEN",        "norm",    2L,         8L,      65L,
  "tier_3", "GEN",        "early",   1L,         8L,      61L,
  "tier_3", "GEN",        "vested",  1L,         8L,       0L
)

saveRDS(status_paths, file.path(staged, "status_paths.rds"))
cat("Saved status_paths.rds:", nrow(status_paths), "rows\n")

# ---------------------------------------------------------------------------
# 4. status_priority
# ---------------------------------------------------------------------------
status_priority <- tribble(
  ~status,      ~priority,
  "norm",         1L,
  "early",        2L,
  "vested",       3L,
  "non_vested",   4L
)

saveRDS(status_priority, file.path(staged, "status_priority.rds"))
cat("Saved status_priority.rds:", nrow(status_priority), "rows\n")

# ---------------------------------------------------------------------------
# 5. benefit_multipliers
#
# Priority-ordered rules: for a given class/tier/status, rules are checked
# in ascending priority order (1 = first). First matching rule wins.
# Matching: yos >= min_yos AND (is.na(min_age) OR dist_age >= min_age)
#                            AND (is.na(max_age) OR dist_age < max_age)
#
# Status values:
#   "norm"  = normal retirement (full benefit)
#   "early" = early retirement (benmult is BASE rate; reduce_factor applied separately)
#
# Notes:
#   - regular tier_1: graduated multiplier by dist_age (AV2022 p.A-22)
#   - admin: always gets special risk rate (0.0300); regular-class rates are
#     never triggered because special risk criteria dominate (see benefit_functions.R)
#   - tier_3: same multipliers as tier_2 (same plan provisions, entry_year >= 2024)
#   - judges, eso, eco: flat 0.0333 / 0.0300 regardless of age graduation
#   - senior_management: flat 0.0200
# ---------------------------------------------------------------------------

bm <- tribble(
  ~class,              ~tier,    ~status, ~priority, ~min_yos, ~min_age, ~max_age, ~benmult,

  # ---- regular tier_1 norm: graduated by dist_age -------------------------
  # Highest rate first (priority 1). Each rule: yos-only OR age+yos path.
  "regular", "tier_1", "norm",   1L,  33L,  NA,  NA,  0.0168,  # yos >= 33
  "regular", "tier_1", "norm",   2L,   6L,  65L, NA,  0.0168,  # age >= 65 AND yos >= 6
  "regular", "tier_1", "norm",   3L,  32L,  NA,  NA,  0.0165,  # yos >= 32
  "regular", "tier_1", "norm",   4L,   6L,  64L, 65L, 0.0165,  # 64 <= age < 65, yos >= 6
  "regular", "tier_1", "norm",   5L,  31L,  NA,  NA,  0.0163,
  "regular", "tier_1", "norm",   6L,   6L,  63L, 64L, 0.0163,
  "regular", "tier_1", "norm",   7L,  30L,  NA,  NA,  0.0160,
  "regular", "tier_1", "norm",   8L,   6L,  62L, 63L, 0.0160,

  # ---- regular tier_1 early -----------------------------------------------
  "regular", "tier_1", "early",  1L,   6L,  NA,  NA,  0.0160,

  # ---- regular tier_2 norm ------------------------------------------------
  "regular", "tier_2", "norm",   1L,  33L,  NA,  NA,  0.0160,
  "regular", "tier_2", "norm",   2L,   8L,  65L, NA,  0.0160,

  # ---- regular tier_2 early -----------------------------------------------
  "regular", "tier_2", "early",  1L,   8L,  NA,  NA,  0.0160,

  # ---- regular tier_3 (same multipliers as tier_2) ------------------------
  "regular", "tier_3", "norm",   1L,  33L,  NA,  NA,  0.0160,
  "regular", "tier_3", "norm",   2L,   8L,  65L, NA,  0.0160,
  "regular", "tier_3", "early",  1L,   8L,  NA,  NA,  0.0160,

  # ---- special tier_1 norm ------------------------------------------------
  "special", "tier_1", "norm",   1L,  25L,  NA,  NA,  0.0300,  # yos >= 25
  "special", "tier_1", "norm",   2L,   6L,  55L, NA,  0.0300,  # age >= 55, yos >= 6

  # ---- special tier_1 early -----------------------------------------------
  "special", "tier_1", "early",  1L,   6L,  NA,  NA,  0.0300,

  # ---- special tier_2 norm ------------------------------------------------
  "special", "tier_2", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "special", "tier_2", "norm",   2L,   8L,  60L, NA,  0.0300,

  # ---- special tier_2 early -----------------------------------------------
  "special", "tier_2", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- special tier_3 (same as tier_2) ------------------------------------
  "special", "tier_3", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "special", "tier_3", "norm",   2L,   8L,  60L, NA,  0.0300,
  "special", "tier_3", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- admin tier_1 norm --------------------------------------------------
  # Admin always gets special risk rate (0.0300); regular-class graduated rates
  # are never triggered because special risk eligibility always dominates.
  # See: benefit_functions.R normal_result() comment "Special Risk rate dominates"
  "admin",   "tier_1", "norm",   1L,  25L,  NA,  NA,  0.0300,  # yos >= 25 (SPEC path)
  "admin",   "tier_1", "norm",   2L,   6L,  55L, NA,  0.0300,  # age >= 55, yos >= 6

  # ---- admin tier_1 early -------------------------------------------------
  "admin",   "tier_1", "early",  1L,   6L,  NA,  NA,  0.0300,

  # ---- admin tier_2 norm --------------------------------------------------
  "admin",   "tier_2", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "admin",   "tier_2", "norm",   2L,   8L,  60L, NA,  0.0300,

  # ---- admin tier_2 early -------------------------------------------------
  "admin",   "tier_2", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- admin tier_3 (same as tier_2) -------------------------------------
  "admin",   "tier_3", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "admin",   "tier_3", "norm",   2L,   8L,  60L, NA,  0.0300,
  "admin",   "tier_3", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- judges tier_1 norm -------------------------------------------------
  "judges",  "tier_1", "norm",   1L,  30L,  NA,  NA,  0.0333,
  "judges",  "tier_1", "norm",   2L,   6L,  62L, NA,  0.0333,

  # ---- judges tier_1 early ------------------------------------------------
  "judges",  "tier_1", "early",  1L,   6L,  NA,  NA,  0.0333,

  # ---- judges tier_2 norm -------------------------------------------------
  "judges",  "tier_2", "norm",   1L,  33L,  NA,  NA,  0.0333,
  "judges",  "tier_2", "norm",   2L,   8L,  65L, NA,  0.0333,

  # ---- judges tier_2 early ------------------------------------------------
  "judges",  "tier_2", "early",  1L,   8L,  NA,  NA,  0.0333,

  # ---- judges tier_3 (same as tier_2) -------------------------------------
  "judges",  "tier_3", "norm",   1L,  33L,  NA,  NA,  0.0333,
  "judges",  "tier_3", "norm",   2L,   8L,  65L, NA,  0.0333,
  "judges",  "tier_3", "early",  1L,   8L,  NA,  NA,  0.0333,

  # ---- eso tier_1 norm ----------------------------------------------------
  "eso",     "tier_1", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "eso",     "tier_1", "norm",   2L,   6L,  62L, NA,  0.0300,
  "eso",     "tier_1", "early",  1L,   6L,  NA,  NA,  0.0300,

  # ---- eso tier_2 norm ----------------------------------------------------
  "eso",     "tier_2", "norm",   1L,  33L,  NA,  NA,  0.0300,
  "eso",     "tier_2", "norm",   2L,   8L,  65L, NA,  0.0300,
  "eso",     "tier_2", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- eso tier_3 (same as tier_2) ----------------------------------------
  "eso",     "tier_3", "norm",   1L,  33L,  NA,  NA,  0.0300,
  "eso",     "tier_3", "norm",   2L,   8L,  65L, NA,  0.0300,
  "eso",     "tier_3", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- eco tier_1 norm (same as eso) --------------------------------------
  "eco",     "tier_1", "norm",   1L,  30L,  NA,  NA,  0.0300,
  "eco",     "tier_1", "norm",   2L,   6L,  62L, NA,  0.0300,
  "eco",     "tier_1", "early",  1L,   6L,  NA,  NA,  0.0300,

  # ---- eco tier_2 norm ----------------------------------------------------
  "eco",     "tier_2", "norm",   1L,  33L,  NA,  NA,  0.0300,
  "eco",     "tier_2", "norm",   2L,   8L,  65L, NA,  0.0300,
  "eco",     "tier_2", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- eco tier_3 (same as tier_2) ----------------------------------------
  "eco",     "tier_3", "norm",   1L,  33L,  NA,  NA,  0.0300,
  "eco",     "tier_3", "norm",   2L,   8L,  65L, NA,  0.0300,
  "eco",     "tier_3", "early",  1L,   8L,  NA,  NA,  0.0300,

  # ---- senior_management tier_1 norm --------------------------------------
  "senior_management", "tier_1", "norm",  1L,  30L,  NA,  NA,  0.0200,
  "senior_management", "tier_1", "norm",  2L,   6L,  62L, NA,  0.0200,
  "senior_management", "tier_1", "early", 1L,   6L,  NA,  NA,  0.0200,

  # ---- senior_management tier_2 norm --------------------------------------
  "senior_management", "tier_2", "norm",  1L,  33L,  NA,  NA,  0.0200,
  "senior_management", "tier_2", "norm",  2L,   8L,  65L, NA,  0.0200,
  "senior_management", "tier_2", "early", 1L,   8L,  NA,  NA,  0.0200,

  # ---- senior_management tier_3 (same as tier_2) --------------------------
  "senior_management", "tier_3", "norm",  1L,  33L,  NA,  NA,  0.0200,
  "senior_management", "tier_3", "norm",  2L,   8L,  65L, NA,  0.0200,
  "senior_management", "tier_3", "early", 1L,   8L,  NA,  NA,  0.0200
)

saveRDS(bm, file.path(staged, "benefit_multipliers.rds"))
cat("Saved benefit_multipliers.rds:", nrow(bm), "rows\n")
cat("\nRow counts by tier:\n")
print(count(bm, tier))
cat("\nRow counts by class/tier/status:\n")
print(count(bm, class, tier, status))
