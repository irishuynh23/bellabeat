######### ANALYZE #############
# Reproducible analysis script for cleaned datasets.

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
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
clean_dir <- file.path(project_root, "dataset", "cleaned_data")
figures_dir <- file.path(project_root, "assets", "dashboard")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

daily_merge <- read_csv(
  file.path(clean_dir, "dailySleepActivity_merged_cleaned.csv"),
  show_col_types = FALSE
)

hourly_steps <- read_csv(
  file.path(clean_dir, "hourlySteps_cleaned.csv"),
  show_col_types = FALSE
)

hourly_intensities <- read_csv(
  file.path(clean_dir, "hourlyIntensities_cleaned.csv"),
  show_col_types = FALSE
)

hourly_calories <- read_csv(
  file.path(clean_dir, "hourlyCalories_cleaned.csv"),
  show_col_types = FALSE
)

# Core summary table used in README documentation
kpi_summary <- tibble(
  avg_daily_steps = mean(daily_merge$TotalSteps, na.rm = TRUE),
  avg_daily_sleep_minutes = mean(daily_merge$TotalMinutesAsleep, na.rm = TRUE),
  avg_daily_sedentary_minutes = mean(daily_merge$SedentaryMinutes, na.rm = TRUE),
  pct_below_7500_steps = mean(daily_merge$TotalSteps < 7500, na.rm = TRUE),
  pct_below_7h_sleep = mean(daily_merge$TotalMinutesAsleep < 420, na.rm = TRUE)
)

write_csv(kpi_summary, file.path(clean_dir, "kpi_summary.csv"))

# Plot 1: Sleep vs sedentary behavior
plot_sleep_vs_sedentary <- ggplot(
  daily_merge,
  aes(x = TotalMinutesAsleep, y = SedentaryMinutes)
) +
  geom_point(alpha = 0.5, color = "#3A86FF") +
  geom_smooth(method = "lm", se = FALSE, color = "#1D3557") +
  labs(
    title = "Sleep vs Sedentary Minutes",
    x = "Minutes Asleep",
    y = "Sedentary Minutes"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(figures_dir, "sleep_vs_sedentary.png"),
  plot = plot_sleep_vs_sedentary,
  width = 8,
  height = 5,
  dpi = 300
)

# Plot 2: Steps vs calories
plot_steps_vs_calories <- ggplot(
  daily_merge,
  aes(x = TotalSteps, y = Calories)
) +
  geom_point(alpha = 0.5, color = "#FF006E") +
  geom_smooth(method = "lm", se = FALSE, color = "#9D0208") +
  labs(
    title = "Daily Steps vs Calories",
    x = "Total Steps",
    y = "Calories"
  ) +
  theme_minimal()

ggsave(
  filename = file.path(figures_dir, "steps_vs_calories.png"),
  plot = plot_steps_vs_calories,
  width = 8,
  height = 5,
  dpi = 300
)

# Plot 3: Hourly pattern table output for Tableau
hourly_pattern <- hourly_steps %>%
  group_by(stepsHour) %>%
  summarise(avg_steps = mean(StepTotal, na.rm = TRUE), .groups = "drop") %>%
  left_join(
    hourly_intensities %>%
      group_by(intHour) %>%
      summarise(avg_intensity = mean(TotalIntensity, na.rm = TRUE), .groups = "drop"),
    by = c("stepsHour" = "intHour")
  ) %>%
  left_join(
    hourly_calories %>%
      group_by(calHour) %>%
      summarise(avg_calories = mean(Calories, na.rm = TRUE), .groups = "drop"),
    by = c("stepsHour" = "calHour")
  ) %>%
  arrange(stepsHour)

write_csv(hourly_pattern, file.path(clean_dir, "hourly_pattern_summary.csv"))

cat("Analysis outputs written to:", clean_dir, "and", figures_dir, "\n")
                           
