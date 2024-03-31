

source(fs::path(here::here("data-raw", "frs"), "_common_frs.R"))

tmp <- pendata::frs$retirement_rates

count(tmp, retirement_type)
count(tmp, retirement_type, tier)

skim(tmp |>
       filter(retirement_type=="normal retirement", tier=="tier2"))

tmp |>
  summarise(minage=min(age), maxage=max(age), .by=c(retirement_type, tier))

# retirement_type   tier  minage maxage
# <chr>             <chr>  <dbl>  <dbl>
# 1 normal retirement tier1     45     80
# 2 normal retirement tier2     50     80
# 3 early retirement  tier1     52     80
# 4 early retirement  tier2     55     80
# 5 drop entry        tier1     45     80
# 6 drop entry        tier2     45     80
