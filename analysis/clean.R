######### PROCESS / CLEAN ###############
# This script only reads from dataset/Raw Data and writes cleaned CSVs
# to dataset/cleaned_data. Fitabase date-range folders are intentionally excluded.

suppressPackageStartupMessages({
  library(dplyr)
  library(lubridate)
  library(readr)
  library(tidyr)
})

get_project_root <- function() {
  candidates <- c(getwd(), dirname(getwd()))
  for (candidate in candidates) {
    if (dir.exists(file.path(candidate, "dataset")) &&
        dir.exists(file.path(candidate, "analysis"))) {
      return(normalizePath(candidate))
    }
  }
  stop("Could not locate project root. Run from the project root or analysis folder.")
}

project_root <- get_project_root()
raw_dir <- file.path(project_root, "dataset", "Raw Data")
clean_dir <- file.path(project_root, "dataset", "cleaned_data")
dir.create(clean_dir, recursive = TRUE, showWarnings = FALSE)

# Importing data from dataset/Raw Data only
activity <- read_csv(file.path(raw_dir, "dailyActivity_merged.csv"), show_col_types = FALSE)
calories <- read_csv(file.path(raw_dir, "hourlyCalories_merged.csv"), show_col_types = FALSE)
intensities <- read_csv(file.path(raw_dir, "hourlyIntensities_merged.csv"), show_col_types = FALSE)
steps <- read_csv(file.path(raw_dir, "hourlySteps_merged.csv"), show_col_types = FALSE)
sleep_day <- read_csv(file.path(raw_dir, "sleepDay_merged.csv"), show_col_types = FALSE)
weight_log <- read_csv(file.path(raw_dir, "weightLogInfo_merged.csv"), show_col_types = FALSE)

# Remove duplicated rows
activity <- distinct(activity)
calories <- distinct(calories)
intensities <- distinct(intensities)
steps <- distinct(steps)
sleep_day <- distinct(sleep_day)
weight_log <- distinct(weight_log)

# Standardize date fields
activity <- activity %>%
  mutate(date = mdy(ActivityDate)) %>%
  select(-ActivityDate)

sleep_day <- sleep_day %>%
  mutate(date = mdy_hms(SleepDay), date = as.Date(date)) %>%
  select(-SleepDay)

calories_clean <- calories %>%
  mutate(
    date_time = mdy_hms(ActivityHour),
    date = as.Date(date_time),
    calHour = format(date_time, "%H:%M:%S")
  ) %>%
  select(Id, date, calHour, Calories)

intensities_clean <- intensities %>%
  mutate(
    date_time = mdy_hms(ActivityHour),
    date = as.Date(date_time),
    intHour = format(date_time, "%H:%M:%S")
  ) %>%
  select(Id, date, intHour, TotalIntensity, AverageIntensity)

steps_clean <- steps %>%
  mutate(
    date_time = mdy_hms(ActivityHour),
    date = as.Date(date_time),
    stepsHour = format(date_time, "%H:%M:%S")
  ) %>%
  select(Id, date, stepsHour, StepTotal)

# Daily merge used by downstream analysis
daily_merge <- sleep_day %>%
  inner_join(activity, by = c("Id", "date"))

# Write cleaned outputs
write_csv(activity, file.path(clean_dir, "dailyActivity_cleaned.csv"))
write_csv(sleep_day, file.path(clean_dir, "sleepDay_cleaned.csv"))
write_csv(weight_log, file.path(clean_dir, "weightLogInfo_cleaned.csv"))
write_csv(calories_clean, file.path(clean_dir, "hourlyCalories_cleaned.csv"))
write_csv(intensities_clean, file.path(clean_dir, "hourlyIntensities_cleaned.csv"))
write_csv(steps_clean, file.path(clean_dir, "hourlySteps_cleaned.csv"))
write_csv(daily_merge, file.path(clean_dir, "dailySleepActivity_merged_cleaned.csv"))

cat("Cleaned datasets written to:", clean_dir, "\n")