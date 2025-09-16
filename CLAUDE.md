# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The `pendata` R package extracts and processes pension plan data for use by the `penmod` package. For each pension plan, it:
1. Extracts data from prepared XLSM files
2. Prepares data tables and objects needed for `penmod`
3. Consolidates objects into a named list (e.g., `frs`)
4. Saves the list as an RDA file in the `data/` folder for export

## Development Commands

### Package Development
- **Build and install package**: Use the `buildit()` function from `R/internal_functions.R` - this handles unloading, cleaning, documenting, and reinstalling the package
- **Run tests**: `devtools::test()` or `testthat::test_check("pendata")`
- **Document package**: `devtools::document()`
- **Load package**: `library(pendata)`

### Plan-Specific Operations
- **Reset plan files**: Use `reset_all("planname")` to list files or `reset_all("planname", delete = TRUE)` to delete all working and final files for a plan
- **Test specific plans**: Tests are located in `data-raw/plans/tests/testthat/`

## Architecture and Structure

### Key Directories
- `R/`: Package source code with internal functions
- `data/`: Final RDA files for each pension plan (exported to `penmod`)
- `data-raw/`: Main development workspace containing:
  - `R/`: Shared utility functions (`functions.R`, `constants.R`, `functions_folders.R`)
  - `plans/`: Individual plan directories (e.g., `frs/`, `txtrs/`)
  - `claude/`: Quarto documentation and analysis

### Plan Directory Structure
Each plan (e.g., `data-raw/plans/frs/`) contains:
- `R/`: Plan-specific functions (benefit calculations, lookups)
- `source_data/`: Original XLSM and related files
- `extracted_data/`: Raw extracted data from XLSM files
- `work_data/`: Intermediate processing files (.rds, .csv)
- `staged_data/`: Final processed data ready for consolidation
- `qmd/`: Quarto documents for plan analysis
- `backups/`: Historical data versions

### Core Workflow
1. Extract data from XLSM files into `extracted_data/`
2. Process and transform data, saving intermediate results to `work_data/`
3. Stage final data objects in `staged_data/`
4. Consolidate into a single plan list and save to `data/planname.rda`

### Key Utility Functions
- `flip()` and `flip_stack()`: Transform wide pension data tables to long format with age/years-of-service dimensions
- `all_tests_passed()`: Check if all tests in a test results list passed
- Directory management functions in `functions_folders.R`

### Constants
Global constants are defined in `data-raw/R/constants.R`:
- Age range: 18-110
- Years of service range: 0-70

### Testing Strategy
- Package-level tests use standard `testthat` framework
- Plan-specific tests are in `data-raw/plans/tests/testthat/`
- Use `all_tests_passed()` helper to evaluate test results programmatically

### Documentation
- Quarto books are used for plan analysis documentation
- Main documentation workspace is in `data-raw/claude/`
- Individual plan documentation in respective `qmd/` directories