
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Constructing data for Florida FRS

- The `.R` files in this folder create individual `.rds` data files that
  will not be released with the `pendata` package. These `.rds` files
  are used to create a list of data objects, called `frs`, that will be
  saved in the `data` folder and released with the package.

- Except where noted, each `.R` file stands alone and can be run to
  create its corresponding `.rds` file. For example, `mortality_rates.R`
  creates `mortality_rates.rds`. There may be one or two `.R` files that
  read in results of other `.R` files, but I have tried to minimize
  that.

- In general, it will be best to step through the `.R` files line by
  line or block by block.

- After creating all the necessary `.rds` files, step through
  `assemble_list.R` to create the `frs.rda` file, which contains the
  list of data objects, `frs`, saved to the `data` folder.

My goal at this point is to create data objects that have information
identical to what the Reason FRS model has, but with structures that (1)
can be used in a consistent manner for other pension systems, and (2)
will be efficient when read into a pension analysis model. The data
package should have all data that do not need to be changed in the
model.

I am working my way through the Reason model programs, starting with
“Florida FRS model input.R”, and then moving on to other program.
Because the Reason model extends and enhances some of the data after it
runs “Florida FRS model input.R”, I expect to extend and enhance some of
the data in this package based on transformations done in the other
Reason programs.

Note that I have not included the dataframe `return_scenarios`, created
in Reason’s “Florida FRS model input.R”, in `pendata` because it
contains assumptions about investment returns that we will want to vary
in a model rather than freeze in static data files.