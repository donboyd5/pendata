
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Constructing data for Florida FRS

- The `.R` files in this folder create individual `.rds` data files that
  will not be released with the `pendata` package. These `.rds` files
  are used to create a list of data objects, called `frs`, that will be
  saved in the `../data` folder and released with the package.

- Except where noted, each `.R` file stands alone and can be run to
  create its corresponding `.rds` file. For example, `mortality_rates.R`
  creates `mortality_rates.rds`. There may be one or two `.R` files that
  read in results of other `.R` files, but I have tried to minimize
  that.

- In general, it will be best to step through the `.R` files line by
  line or block by block.

- After creating all the necessary `.rds` files, step through
  `assemble_list.R` to create the `frs.rda` file, which contains the
  list of data objects, `frs`, saved to the `../data` folder.
