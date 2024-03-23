
# frs: Florida Retirement System

# morality rates


# setup -------------------------------------------------------------------

draw <- here::here("data-raw")
dfrs <- fs::path(draw, "systems", "frs")

source(here::here("data-raw", "libraries.r"))
source(fs::path(dfrs, "functions_tier.r"))
source(fs::path(dfrs, "constants.r"))


# get SOA data ----------------------------------------------------------------

mort1 <- pendata::pub2010hc_mortality_rates |>
  mutate(system="frs") |>
  relocate(system)

glimpse(mort1)
ht(mort1)
count(mort1, employee_type)
count(mort1, beneficiary_type)
count(mort1, gender)
count(mort1, age) |> ht()


# base mortality table ------------------------------------

# base mortality table: per Reason:
#   regular: average of SOA general and teacher mortality tables (Florida FRS benefit model.R, line 172)
#   special, admin – use SOA safety (Florida FRS benefit model.R, lines 258-264)
#   eco, eso, judges, senior_management - use SOA general (Florida FRS benefit model.R, lines 258-264)

# create the regular table and add it to mort
# general has 626 records, teachers has 616 records when does one have values but not the other
mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  arrange(beneficiary_type, gender, age, employee_type) |>
  group_by(beneficiary_type, gender, age) |>
  mutate(nnotna=sum(!is.na(rate))) |>
  filter(nnotna != 2)
# issue arises for beneficiary_type healthy_retiree male and female ages 50-54 where
#   we have not na values for general but values for teachers are na

# follow the reason approach
regular_mort <- mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  pivot_wider(names_from = beneficiary_type, values_from = rate) |>
  # address missing values in the same way as Reason does
  mutate(employee = ifelse(is.na(employee), healthy_retiree, employee),
         healthy_retiree = ifelse(is.na(healthy_retiree), employee, healthy_retiree)) |>
  pivot_longer(cols = -c(system, employee_type, gender, age),
               names_to = "beneficiary_type",
               values_to = "rate") |>
  # DO NOT use na.rm = TRUE as we have addressed the only case where we have values
  # for one group (general) but not another (teachers)
  summarise(rate=mean(rate), .by=c(system, beneficiary_type, gender, age)) |>
  mutate(employee_type = "regular") |>
  arrange(system, employee_type, beneficiary_type, gender, age)

mort1 |>
  filter(employee_type %in% c("general", "teachers")) |>
  filter(beneficiary_type ==  "healthy_retiree", gender=="female", age %in% 50:56)
regular_mort |> filter(beneficiary_type ==  "healthy_retiree", gender=="female", age %in% 50:56)

base_mort <- bind_rows(
  mort1 |> filter(employee_type %in% c("general", "safety")),
  regular_mort)

glimpse(base_mort)
count(base_mort, employee_type)

saveRDS(base_mort, path(dfrs, "base_mortality_rates.rds"))


# construct crosswalk between employee class and employee type ------------
# define which base mortality rates to use for each class
class_mortality_xwalk <- tibble(class = frs_constants$classes) |>
  mutate(employee_type =
           case_when(class == "regular" ~ "regular",
                     class %in% c("special", "admin") ~ "safety",
                     class %in% c("eco", "eso", "judges",
                                  "senior_management") ~ "general"))

class_mortality_xwalk

saveRDS(class_mortality_xwalk, path(dfrs, "class_mortality_xwalk.rds"))


# entry_year_range_ 1970:2052

# construct mortality rates with mortality improvement ------------

# final_mort_table for regular has
#  entry_year (1970:2052)
#  entry_age (18:65 by 5 = 11)
#  dist_age (18:120)
#  yos (0:70)
# = 83 x 11 x 103 x 71 = 6.677 million combinations

# term_year = entry_year + yos
# dist_year = entry_year + dist_age - entry_age
# filter(term_year <= dist_year) leaves 2.977 million

# depends on dist_year, age, yos, tier or class

# I think we need improved mortality rates for each:

# unique for each: class, tier_at_dist_age, dist_year, dist_age

## prep mortality ----
# The only mortality categories Reason uses are:
#   employee, for vested tiers
#   healthy_retiree for others
# In all cases, they first calc improved mortality for males and females,
# then average male and female.

count(base_mortality_rates, employee_type)
count(base_mortality_rates, beneficiary_type)

bmprep <- base_mortality_rates |>
  filter(!is.na(rate)) |> # should I do this?? djb
  filter(beneficiary_type %in% c("employee", "healthy_retiree")) |>
  select(employee_type, beneficiary_type, gender, dist_age=age, rate)

emptypes <- class_mortality_xwalk |>
  pull(employee_type) |>
  unique()

base <- expand_grid(employee_type=emptypes,
                    dist_year=1970:2154,
                    dist_age=18:120) |>
  filter((dist_year - dist_age) %in% 1905:2034) # birth year -- mentally add 120 for max year

# mutate(yob=dist_year - dist_age,
#        firstty=yob + 18) |>
#   relocate(firstty, dist_year) |>
#   filter(firstty > dist_year)

base2 <- base |>
  left_join(bmprep,
            by = join_by(employee_type, dist_age),
            relationship = "many-to-many") |>
  left_join(mprates |>
              select(dist_year=year, dist_age=age, gender, mp_cumprod_adj=mpcadj),
            by = join_by(dist_year, dist_age, gender)) |>
  relocate(dist_age, dist_year, .before = rate) |>
  arrange(employee_type, beneficiary_type, gender, dist_age, dist_year) |>
  mutate(mort=rate * mp_cumprod_adj)
skim(base2)

# now get the average of male and female mortality rates, after projecting them separately

mort_final <- base2 |>
  summarise(mort_final=mean(mort),
            .by=c(employee_type, beneficiary_type, dist_age, dist_year))
skim(mort_final) # 57,428 records, vs maybe 21m records (7 classes x 3m records) in Reason model
saveRDS(mort_final, fs::path(dfrs, "mortality_final.rds"))


# are there any unique mortality rates in the Reason mortality table that are not in this one? ----
mt <- readRDS(fs::path(dfrs, "mortality_final.rds"))
rmt <- readRDS(fs::path(dfrs, "from_reason", "regular_mort_table.rds"))

skim(mt) # use bene type for grouping
skim(rmt)

glimpse(mt)
glimpse(rmt) # include tier for grouping

# get comparable groupings for rmt and mt
glimpse(rmt)
rmtg <- rmt |>
  mutate(beneficiary_type=if_else(
    str_detect(tier_at_dist_age, "vested"),
    "employee", "healthy_retiree")) |>
  select(beneficiary_type, dist_year, dist_age, mort_final) |>
  distinct() # |>    mutate(nrsn=n(), .by=dist_year, dist_age)
skim(rmtg)
ht(rmtg)

mtg <- mt |>
  filter(employee_type=="regular") |>
  select(beneficiary_type, dist_year, dist_age, mort_final) |>
  distinct() # |>  mutate(ndjb=n(), .by=dist_year, dist_age)
skim(mtg)

comp <- bind_rows(
  rmtg |> mutate(src="reason"),
  mtg |> mutate(src="boyd"))

compw <- comp |>
  pivot_wider(names_from = src, values_from = mort_final)

compw |>
  filter(!is.na(reason), !is.na(boyd)) |>
  filter(reason != boyd) # good, zero

compw |>
  filter(!is.na(reason), is.na(boyd)) # good, zero

bad <- compw |>
  filter(is.na(reason), !is.na(boyd)) # 3,548

count(bad, beneficiary_type)
count(bad, dist_year) |> ht()
count(bad, dist_age) |> ht()
count(bad, beneficiary_type, dist_year, dist_age)

bad |> filter(beneficiary_type=="employee")

bad2 <- count(bad, beneficiary_type, dist_year, dist_age) |>
  left_join(rmtg, by = join_by(beneficiary_type, dist_year, dist_age)) |>
  mutate(yob=dist_year - dist_age)
skim(bad2)
bad2 |>
  skim()

bad2 |>
  summarise(minyob=min(yob), maxyob=max(yob), minage=min(dist_age), maxage=max(dist_age),
            maxyod=max(yob + 120),
            .by=c(beneficiary_type, dist_year)) |>
  arrange(minyob)

bad |>
  mutate(yob=dist_year - dist_age,
         firstty=yob + 18) |>
  relocate(firstty, dist_year) |>
  filter(firstty > dist_year)



# test --------------------------------------------------------------------



mt <- readRDS(fs::path(dfrs, "mortality_final.rds"))
rmt <- readRDS(fs::path(dfrs, "from_reason", "regular_mort_table.rds"))
skim(rmt)

base_mortality_rates <- readRDS(fs::path(dfrs, "base_mortality_rates.rds"))
mprates <- readRDS(fs::path(dfrs, "mortality_improvement.rds"))





# tmp <- base2 |>
#   filter(employee_type=="general",
#          beneficiary_type=="employee",
#          gender=="female",
#          dist_age %in% c(18))
# note that we don't have mortality improvement for 18 year olds past
# 2052. An 18 year old in 2052 will still get the 19 year old mortality
# improvement in 2053, and so on, so we have enough data for them. If this
# does present a problem, we can keep more data

# base2 |>
#   filter(employee_type=="general",
#          beneficiary_type=="employee",
#          # gender=="female",
#          dist_age==18) |>
#   ggplot(aes(x=dist_year, y=mort, colour=gender)) +
#   geom_point() +
#   geom_line()



# final_mort_table <- expand_grid(entry_year = entry_year_range_, entry_age = entrant_profile$entry_age, dist_age = age_range_, yos = yos_range_) %>%
#   mutate(
#     term_year = entry_year + yos,
#     dist_year = entry_year + dist_age - entry_age
#   )  %>%
#   filter(term_year <= dist_year) %>%
#   arrange(entry_year, entry_age, yos, dist_age) %>%
# left_join(base_mort_table, by = c("dist_age" = "age")) %>%
#   left_join(male_mp_final_table, by = c("dist_age" = "age", "dist_year" = "year")) %>%
#   left_join(female_mp_final_table, by = c("dist_age" = "age", "dist_year" = "year")) %>%
#   mutate(
#     tier_at_dist_age = get_tier(class_name, entry_year, dist_age, yos),
#
#     male_mort = if_else(str_detect(tier_at_dist_age, "vested"), employee_male,
#                         healthy_retiree_male) * male_mp_cumprod_adj,
#
#     female_mort = if_else(str_detect(tier_at_dist_age, "vested"), employee_female,
#                           healthy_retiree_female) * female_mp_cumprod_adj,
#
#     mort_final = (male_mort + female_mort)/2
#   )

count(base, entry_year, dist_year)

check <- rmt |>
  count(entry_year, dist_year, dist_age)





# FOR TESTING AND QC compare ----
rmtdjb <- readRDS(fs::path(dfrs, "from_reason", "rmtdjb.rds"))
rmt <- readRDS(fs::path(dfrs, "from_reason", "regular_mort_table.rds"))
glimpse(rmt) # Rows: 2,977,459
length(unique(rmt$mort_final)) # 14915


a <- proc.time()
djb <- rmt |>
  select(entry_year, dist_age, yos, tier_at_dist_age) |>
  mutate(class="regular") |>
  mutate(tier=get_tier(class, entry_year, dist_age, yos, frs_constants$new_year)) # my get_tier
b <- proc.time()
b - a


count(djb, tier_at_dist_age, tier) |>
  filter(tier_at_dist_age != tier)

# entry_year entry_age dist_year dist_age yos term_year mort_final tier_at_dist_age

# it looks like we have 38,583 unique combinations of mortality rates for class regular,
# uniquely determined by tier_at_dist_age, dist_age, and dist_year
# with 7 classes, total uniques might be abotu 280k

# counts <- rmt |>
#   summarise(n=n(), nunique=length(unique(mort_final)),
#             .by=c(tier_at_dist_age, entry_year, entry_age, dist_age))
#
# counts <- rmt |>
#   summarise(n=n(), nunique=length(unique(mort_final)),
#             .by=c(tier_at_dist_age, entry_year, dist_year, dist_age))
#
# counts <- rmt |>
#   summarise(n=n(), nunique=length(unique(mort_final)),
#             .by=c(dist_year, dist_age))

counts <- rmt |>
  summarise(n=n(), nunique=length(unique(mort_final)),
            .by=c(tier_at_dist_age, dist_year, dist_age))

counts |>
  mutate(yob=dist_year - dist_age) |>
  summarise(minyob=min(yob), maxyob=max(yob))

tmp <- rmt |>
  arrange(tier_at_dist_age, dist_year, dist_age) |>
  select(tier_at_dist_age, dist_year, dist_age, everything())

max(counts$nunique)

count(counts, dist_age) |> ht()
count(counts, dist_year) |> ht()
count(counts, tier_at_dist_age)
tmp <- rmt |> select(tier_at_dist_age, )
# 12 tiers: (early, non_vested, norm, vested) x 3 tiers
skim(counts)
# dist_year: 1970:2154
count(counts, dist_year) |> ht()
counts |> filter(dist_year >= 2150)
nrow(counts)
length(unique(rmt$mort_final))





# get_tier <- function(class_name, entry_year, age, yos){
#   tier = if_else(entry_year < 2011,
#                  case_when(
#                    class_name %in% c("special", "admin") & (yos >= 25 | (age >= 55 & yos >= 6) | (age >= 52 & yos >= 25)) ~ "tier_1_norm",
#                    yos >= 30 | (age >= 62 & yos >= 6) ~ "tier_1_norm",
#                    class_name %in% c("special", "admin") & (yos >= 6 & age >= 53) ~ "tier_1_early",
#                    (yos >= 6 & age >= 58) ~ "tier_1_early",
#                    yos >= 6 ~ "tier_1_vested",
#                    .default = "tier_1_non_vested"
#                  ),
#                  if_else(entry_year < new_year_,
#                          case_when(
#                            class_name %in% c("special", "admin") & (yos >= 30 | (age >= 60 & yos >= 8)) ~ "tier_2_norm",
#                            yos >= 33 | (age >= 65 & yos >= 8) ~ "tier_2_norm",
#                            class_name %in% c("special", "admin") & (yos >= 8 & age >= 56) ~ "tier_2_early",
#                            (yos >= 8 & age >= 61) ~ "tier_2_early",
#                            yos >= 8 ~ "tier_2_vested",
#                            .default = "tier_2_non_vested"
#                          ),
#                          case_when(
#                            class_name %in% c("special", "admin") & (yos >= 30 | (age >= 60 & yos >= 8)) ~ "tier_3_norm",
#                            yos >= 33 | (age >= 65 & yos >= 8) ~ "tier_3_norm",
#                            class_name %in% c("special", "admin") & (yos >= 8 & age >= 56) ~ "tier_3_early",
#                            (yos >= 8 & age >= 61) ~ "tier_3_early",
#                            yos >= 8 ~ "tier_3_vested",
#                            .default = "tier_3_non_vested"
#                          )))
#   return(tier)
# }
