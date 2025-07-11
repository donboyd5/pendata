early_result <- function(class) {
  case_when(
    class == "regular" ~ 0.0160,
    class == "special" ~ 0.0300,
    class == "judges" ~ 0.0333,
    class %in% c("eso", "eco") ~ 0.0300,
    class == "senior_management" ~ 0.0200,
    class == "admin" ~ 0.0300, # Admin gets Special Risk rate for early retirement
    .default = 0
  )
}

normal_result <- function(class, tier, dist_age, yos, dist_year) {
  case_when(
    # Regular Tier 1
    class == "regular" &
      tier == "tier_1" &
      ((dist_age >= 65 & yos >= 6) | yos >= 33) ~
      0.0168,
    class == "regular" &
      tier == "tier_1" &
      ((dist_age >= 64 & dist_age < 65 & yos >= 6) | yos >= 32) ~
      0.0165,
    class == "regular" &
      tier == "tier_1" &
      ((dist_age >= 63 & dist_age < 64 & yos >= 6) | yos >= 31) ~
      0.0163,
    class == "regular" &
      tier == "tier_1" &
      ((dist_age >= 62 & dist_age < 63 & yos >= 6) | yos >= 30) ~
      0.0160,

    # Regular Tier 2
    class == "regular" &
      tier == "tier_2" &
      ((dist_age >= 65 & yos >= 8) | yos >= 33) ~
      0.0160,

    # Special Risk Tier 1
    class == "special" &
      tier == "tier_1" &
      ((dist_age >= 55 & yos >= 6) | yos >= 25) ~
      0.0300,

    # Special Risk Tier 2
    class == "special" &
      tier == "tier_2" &
      ((dist_age >= 60 & yos >= 8) | yos >= 30) ~
      0.0300,

    # Admin class - gets maximum of Special Risk or Regular Class benefits
    class == "admin" &
      tier == "tier_1" &
      ((dist_age >= 55 & yos >= 6) |
        yos >= 25 | # Special Risk path
        (dist_age >= 65 & yos >= 6) |
        yos >= 33) ~ # Regular path
      0.0300, # Special Risk rate dominates for Tier 1

    class == "admin" &
      tier == "tier_1" &
      ((dist_age >= 64 & dist_age < 65 & yos >= 6) | yos >= 32) ~
      0.0165, # Regular Class rate when Special Risk doesn't apply

    class == "admin" &
      tier == "tier_1" &
      ((dist_age >= 63 & dist_age < 64 & yos >= 6) | yos >= 31) ~
      0.0163, # Regular Class rate when Special Risk doesn't apply

    class == "admin" &
      tier == "tier_1" &
      ((dist_age >= 62 & dist_age < 63 & yos >= 6) | yos >= 30) ~
      0.0160, # Regular Class rate when Special Risk doesn't apply

    class == "admin" &
      tier == "tier_2" &
      ((dist_age >= 60 & yos >= 8) |
        yos >= 30 | # Special Risk path
        (dist_age >= 65 & yos >= 8) |
        yos >= 33) ~ # Regular path
      0.0300, # Special Risk rate dominates for Tier 2

    # Judges (both tiers)
    class == "judges" &
      tier == "tier_1" &
      ((dist_age >= 62 & yos >= 6) | yos >= 30) ~
      0.0333,
    class == "judges" &
      tier == "tier_2" &
      ((dist_age >= 65 & yos >= 8) | yos >= 33) ~
      0.0333,

    # Elected Officers (ESO/ECO)
    class %in%
      c("eso", "eco") &
      tier == "tier_1" &
      ((dist_age >= 62 & yos >= 6) | yos >= 30) ~
      0.0300,
    class %in%
      c("eso", "eco") &
      tier == "tier_2" &
      ((dist_age >= 65 & yos >= 8) | yos >= 33) ~
      0.0300,

    # Senior Management
    class == "senior_management" &
      tier == "tier_1" &
      ((dist_age >= 62 & yos >= 6) | yos >= 30) ~
      0.0200,
    class == "senior_management" &
      tier == "tier_2" &
      ((dist_age >= 65 & yos >= 8) | yos >= 33) ~
      0.0200,

    # Default for invalid cases
    .default = 0
  )
}

benmult_function <- function(data) {
  data |>
    # Input validation - return 0 for any NA values
    mutate(
      result = case_when(
        if_any(
          .cols = c(class, tier, early_retirement, dist_age, yos, dist_year),
          .fns = is.na
        ) ~
          0,
        early_retirement ~ early_result(class),
        !early_retirement ~
          normal_result(class, tier, dist_age, yos, dist_year),
        .default = 0
      )
    ) |>
    pull(result)
}
