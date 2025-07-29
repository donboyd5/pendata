# pendata

R package with data on public pension plans, for use in the R package `penmod`.

For a given plan, `pendata`:

* extracts data from a previously prepared xlsm file
* prepares data tables and objects needed for `penmod`
* consolidates these objects in a list e.g., `frs`
* puts the list in a `.rda` file in the data folder, for export to and use by `penmod`.
