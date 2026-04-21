# Dataset Guide

## Approved Folders
- Input only: `Raw Data/` (not committed; add CSVs locally after clone)
- Output only: `Cleaned Data/` (committed outputs are **CSV** only; legacy `.xlsx` copies stay local and are gitignored)

## Excluded Folders
Do not use these folders in scripts or analysis:
- `Fitabase Data 4.12.16-5.12.16/`
- `Fitabase Data 3.12.16-4.11.16/`

## Data Source and License
- Source: Fitbit Fitness Tracker Data (Kaggle)
- License: CC0 Public Domain (as cited in case study materials)

## Refresh Steps
1. Place/confirm source CSV files in `Raw Data/`.
2. Run `analysis/clean.R` to regenerate cleaned outputs.
3. Confirm new files in `Cleaned Data/`:
   - `dailyActivity_cleaned.csv`
   - `sleepDay_cleaned.csv`
   - `weightLogInfo_cleaned.csv`
   - `hourlyCalories_cleaned.csv`
   - `hourlyIntensities_cleaned.csv`
   - `hourlySteps_cleaned.csv`
   - `dailySleepActivity_merged_cleaned.csv`
4. Run `analysis/analysis.R` to generate summary outputs for documentation (`hourly_pattern_summary.csv`, `kpi_summary.csv`, and figures under `assets/dashboard/`).
