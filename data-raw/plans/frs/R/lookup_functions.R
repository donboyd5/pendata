benmult_lookup <- function(data, benefit_rules) {
  data |>
    mutate(id = row_number()) |>
    left_join(
      benefit_rules,
      join_by(
        class == class,
        tier == tier,
        early_retirement == early_retirement,
        dist_age >= dist_age_min_ge,
        dist_age < dist_age_max_lt,
        yos >= yos_min_ge,
        yos < yos_max_lt,
        dist_year >= dist_year_min_ge,
        dist_year < dist_year_max_lt
      )
    ) |>
    select(
      -c(
        dist_age_min_ge,
        dist_age_max_lt,
        yos_min_ge,
        yos_max_lt,
        dist_year_min_ge,
        dist_year_max_lt
      )
    ) |>
    mutate(benmult = replace_na(benmult, 0)) |>
    slice_max(benmult, with_ties = FALSE, by = id) |>
    pull(benmult)
}

# test_cases |>
#   mutate(benmult = benmult_lookup(pick(everything()), benefit_rules)) |>
#   mutate(match = abs(benmult - expected_benmult) < 0.0001) |>
#   filter(!match)
