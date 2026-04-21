# Analysis Workflow

This folder contains the reproducible R workflow for cleaning and analyzing Bellabeat data.

## Scripts
- `clean.R`: loads raw CSV files from `dataset/Raw Data/`, cleans/transforms them, and writes standardized CSV outputs to `dataset/cleaned_data/`.
- `analysis.R`: loads cleaned outputs, generates KPI tables and chart assets for the README and `assets/dashboard/`.
- `sourceKaggle.R`: legacy exploratory script kept for reference only.

## Run Order
1. `clean.R`
2. `analysis.R`

## Required R Packages
- `dplyr`
- `tidyr`
- `lubridate`
- `readr`
- `ggplot2`

## Reproducibility Notes
- The scripts auto-detect project root if run from either project root or `analysis/`.
- No `Fitabase Data ...` folders are used in the standardized workflow.
- Interactive calls (for example `View()`) are intentionally removed from the main run path.
