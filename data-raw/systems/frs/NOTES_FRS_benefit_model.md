
# Notes on how “Florida FRS benefit model.R” relates to pendata

## Salary growth

- Truong reads salary growth rates in “Florida FRS model input.R” line
  180

- He extends salary growth to OUR maximum yos in “Florida FRS benefit
  model.R” lines 6-9 by carrying the last yos growth rate (yos=70)
  forward to all subsequent yos (up to 70)

- I do all of this in salary_growth.R

``` r
#Calculate salary cumulative growth 
salary_growth_table <- salary_growth_table_ %>% 
  bind_rows(tibble(yos = (max(salary_growth_table_$yos)+1):max(yos_range_))) %>% 
  fill(everything(), .direction = "down") %>% 
  mutate(across(contains("salary"), ~ cumprod(1 + lag(.x, default = 0)), .names = "cumprod_{.col}"), .keep = "unused")
```

## Salary-headcount table

``` r
#Joining headcount data, salary data, and salary growth data
#We account for the Investment Plan (DC plan) head count by inflating the DB head count by the ratio of total system head count to DB head count
#ECO, ESO, and Judges head counts are processed separately as the ACFR does not provide detailed head counts for these classes 
eco_eso_judges_active_member_adjustment_ratio <- eco_eso_judges_total_active_member_ / sum(eco_headcount_table_[-1] + eso_headcount_table_[-1] + judges_headcount_table_[-1])

get_salary_headcount_table <- function(salary_table, headcount_table, salary_growth_table, class_name){
  
  class_name <- str_replace(class_name, " ", "_")
  
  if (!class_name %in% c("eco", "eso", "judges")) {
    assign("total_active_member", get(paste0(class_name, "_total_active_member_")))
  } else {
    assign("total_active_member", get("eco_eso_judges_total_active_member_"))
  }
  
  salary_growth_table <- salary_growth_table %>% 
    select(yos, contains(class_name)) %>% 
    rename(cumprod_salary_increase = 2)
  
  salary_table_long <- salary_table %>% 
    pivot_longer(cols = -1, names_to = "yos", values_to = "salary")
  
  headcount_table_long <- headcount_table %>% 
    pivot_longer(cols = -1, names_to = "yos", values_to = "count") %>% 
    mutate(
      active_member_adjustment_ratio = if_else(str_detect(class_name, "eco|eso|judges"), eco_eso_judges_active_member_adjustment_ratio, 
                                               total_active_member / sum(count, na.rm = T)),
      count = count * active_member_adjustment_ratio
    ) %>% 
    select(-active_member_adjustment_ratio)
  
  salary_headcount_table <- salary_table_long %>% 
    left_join(headcount_table_long) %>% 
    mutate(
      yos = as.numeric(yos),
      start_year = start_year_,
      entry_age = age - yos,
      entry_year = start_year - yos) %>% 
    filter(!is.na(salary), entry_age >= 18) %>% 
    left_join(salary_growth_table) %>% 
    mutate(entry_salary = salary / cumprod_salary_increase) %>% 
    select(entry_year, entry_age, age, yos, count, entry_salary)
  
  entrant_profile <- salary_headcount_table %>% 
    filter(entry_year == max(entry_year)) %>% 
    mutate(entrant_dist = count/sum(count)) %>% 
    select(entry_age, entry_salary, entrant_dist) %>% 
    rename(start_sal = entry_salary)
  
  output <- list(
    salary_headcount_table = salary_headcount_table, 
    entrant_profile = entrant_profile)
    
  return(output)
}

regular_salary_headcount_table <- get_salary_headcount_table(regular_salary_table_, regular_headcount_table_, salary_growth_table, "regular")$salary_headcount_table
```
