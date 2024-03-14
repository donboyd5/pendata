
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pendata

<!-- badges: start -->
<!-- badges: end -->

Pension data for the Reason-Rockefeller pension policy analysis tool.

For documentation on how to create the data released with this package,
see the README.md files in each pension system’s folder. For example,
the documentation for building data for the Florida Retirement System
(FRS) is [here](../data-raw/systems/frs/README.md).

<!-- For issues that need consideration, see [this](data-raw/misc/issues.md). -->

## Installation

You can install the development version of pendata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("donboyd5/pendata")
```

This package contains pension-related data:

- **Commonly used actuarial tables** from authoritative sources, such as
  the Society of Actuaries’ (SOA) MP-2018 mortality improvement scale.

- **System-specific data**. The package includes mortality tables and
  other data specific to the Florida Retirement System (FRS). We will
  add data from additional plans. The package takes raw data from
  individual pension systems in formats that vary from system to system,
  and converts it to a consistent format that is consistent from system
  to system. For example, mortality tables follow a common format and
  are consistent with the format used for SOA tables.

The package also includes tools to convert data from the package’s
formats to selected other formats.

## Examples

Look at the mp2018 data.

``` r
library(pendata)

# data(package="pendata")

summary(mp2018)
#>     gender               year           age            mp           
#>  Length:16968       Min.   :1951   Min.   : 20   Min.   :-0.043200  
#>  Class :character   1st Qu.:1972   1st Qu.: 45   1st Qu.: 0.000000  
#>  Mode  :character   Median :1992   Median : 70   Median : 0.005900  
#>                     Mean   :1992   Mean   : 70   Mean   : 0.006712  
#>                     3rd Qu.:2013   3rd Qu.: 95   3rd Qu.: 0.012200  
#>                     Max.   :2034   Max.   :120   Max.   : 0.073500
head(mp2018)
#> # A tibble: 6 × 4
#>   gender  year   age     mp
#>   <chr>  <int> <int>  <dbl>
#> 1 female  1951    20 0.0667
#> 2 female  1951    21 0.0691
#> 3 female  1951    22 0.071 
#> 4 female  1951    23 0.0724
#> 5 female  1951    24 0.0732
#> 6 female  1951    25 0.0735
tail(mp2018)
#> # A tibble: 6 × 4
#>   gender  year   age    mp
#>   <chr>  <int> <int> <dbl>
#> 1 male    2034   115     0
#> 2 male    2034   116     0
#> 3 male    2034   117     0
#> 4 male    2034   118     0
#> 5 male    2034   119     0
#> 6 male    2034   120     0
```
