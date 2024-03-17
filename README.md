
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pendata

<!-- badges: start -->
<!-- badges: end -->

Pension data and tools for the Reason-Rockefeller pension policy
analysis model:

- **Commonly used actuarial tables** from authoritative sources such as
  the Society of Actuaries.

- **System-specific data**. The package converts raw demographic,
  actuarial, and other data for a pension system to a consistent format
  for use in the Reason-Rockefeller model.

README files for SOA data and individual systems:

- [SOA](data-raw/soa/README.md)
- [FRS](data-raw/systems/frs/README.md)

<!-- For issues that need consideration, see [this](data-raw/misc/issues.md). -->

## Installation

You can install the development version of pendata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("donboyd5/pendata")
```

## How to build the data in this package

- **SOA**: Go to the data-raw/soa folder and read the README for
  documentation. Step through the individual .R files to build the SOA
  data sets. These must be built first because individual systems may
  base actuarial tables on SOA tables.

- **Individual systems**: Go to the data-raw subfolder for the system,
  such as data-raw/frs for Florida Retirement System (FRS). Read the
  README for documentation and information about which programs to run
  first, because some data depends on data built in earlier steps. Step
  through the individual .R files.
