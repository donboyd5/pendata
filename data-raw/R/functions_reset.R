reset_all <- function(plan) {
  plan_dir <- here::here("data-raw", "plans", plan)
  work <- fs::path(plan_dir, "work")
  staged <- fs::path(plan_dir, "staged")
  return(c(work, staged))
}

reset_all("frs")
