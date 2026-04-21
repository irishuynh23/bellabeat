# 📊 Bellabeat Case Study — Smart Device Usage Analysis

Capstone-style analysis of Fitbit tracker data to infer how people use smart wellness devices, then translate patterns into **product and marketing ideas** for Bellabeat (women-focused health tech).

### The six-step data analysis process

The case study follows the **six-step data analysis process** used in the Google Data Analytics program:

| # | Phase | What this repo covers |
|:---:|:---|:---|
| **1** | **Ask** | Business task, questions, stakeholders |
| **2** | **Prepare** | Data source, scope, what’s in / out of git |
| **3** | **Process** | Cleaning, joins, standardized tables (`clean.R`) |
| **4** | **Analyze** | KPI checks, visuals that support slide findings (`analysis.R`) |
| **5** | **Share** | Canva slides, reproducible R commands, figures |
| **6** | **Act** | Product + marketing recommendations, next data steps |

Below, each step has its **own section** (**1**–**6**) in the same order.

---

## 🔗 Quick links

| 🔎 | Resource |
|---|----------|
| 🎬 | **[Presentation slides (Canva)](https://canva.link/emsulvwxmh7dtii)** — interactive deck |
| 📑 | Slide deck PDF in repo: [`presentation/bellabeat_presentation.pdf`](presentation/bellabeat_presentation.pdf) |
| 📘 | Course case brief: [`bellabeat_case_study.pdf`](bellabeat_case_study.pdf) |

If the Canva link asks for permission, open the design in Canva → **Share → Anyone with the link → View**.

---

## 1. Ask

### 💼 Business task
Understand **trends in non-Bellabeat smart-device usage** (activity, sleep, time of day) and recommend how Bellabeat — especially the **Bellabeat app** — could apply those insights to features and marketing.

### 🤔 Guiding questions
- What trends appear in how people move, rest, and burn energy?
- How could those trends map to Bellabeat customers?
- How could marketing and product prioritize **sleep quality** and **daily movement**?

### 👥 Stakeholders
Marketing analytics and leadership evaluating growth and positioning — context in the **[Bellabeat case study brief (PDF)](bellabeat_case_study.pdf)**.

---

## 2. Prepare

### 📂 Data source
- **Fitbit Fitness Tracker Data** (Kaggle; **CC0** public domain).
- Small convenience sample (~30 consenting users); **not** nationally representative — treat conclusions as directional, not definitive.

### 🗂️ What is in this repository
| Location | Purpose |
|----------|---------|
| `dataset/cleaned_data/*.csv` | Cleaned, analysis-ready tables and summaries |
| `dataset/README.md` | Data conventions and refresh steps |
| `analysis/clean.R` | Load → dedupe → standardize dates → merge → write cleaned CSVs |
| `analysis/analysis.R` | KPI summary, exploratory ggplot, hourly pattern CSV |
| `assets/dashboard/*.png` | Auto-generated exploration plot from `analysis.R` |
| `assets/findings/*.png` | Figures exported for README findings (same variables as your analysis charts) |

### 🚫 What is *not* committed (by design)
- **`dataset/Raw Data/`** — add Kaggle CSVs locally after clone, then run `clean.R`.
- **Legacy Fitabase date-range folders** — excluded from this workflow (see `.gitignore`).

---

## 3. Process

High-level steps in [`analysis/clean.R`](analysis/clean.R):
- Remove duplicate rows.
- Parse activity and sleep dates consistently; split hourly timestamps into **date** + **time-of-day** for steps, intensity, and calories.
- Build **`dailySleepActivity_merged_cleaned.csv`**: inner join of sleep and daily activity on `Id` + `date`.
- Write hourly long-form tables for charts and further visualization.

Below: **code → output** from the same Fitbit CSVs you use locally (`dataset/Raw Data`). Outputs may differ slightly if file versions change.

### Inspect raw inputs

```r
library(readr)

raw_dir <- "dataset/Raw Data"
activity <- read_csv(file.path(raw_dir, "dailyActivity_merged.csv"), show_col_types = FALSE)

colnames(activity)
head(activity, 3)
```

```
 [1] "Id"                       "ActivityDate"
 [3] "TotalSteps"               "TotalDistance"
 [5] "TrackerDistance"          "LoggedActivitiesDistance"
 [7] "VeryActiveDistance"       "ModeratelyActiveDistance"
 [9] "LightActiveDistance"      "SedentaryActiveDistance"
[11] "VeryActiveMinutes"        "FairlyActiveMinutes"
[13] "LightlyActiveMinutes"     "SedentaryMinutes"
[15] "Calories"

# A tibble: 3 × 15
          Id ActivityDate TotalSteps TotalDistance TrackerDistance
       <dbl> <chr>             <dbl>         <dbl>           <dbl>
1 1503960366 4/12/2016         13162          8.5             8.5
2 1503960366 4/13/2016         10735          6.97            6.97
3 1503960366 4/14/2016         10460          6.74            6.74
# ℹ 10 more variables …
```

```r
library(dplyr)
n_distinct(activity$Id)
```

```
[1] 33
```

### Clean dates and merge sleep + daily activity

Paths match [`analysis/clean.R`](analysis/clean.R): `dataset/Raw Data` → reads; `dataset/cleaned_data` → writes.

```r
library(dplyr); library(lubridate); library(readr)

raw_dir <- "dataset/Raw Data"

activity <- read_csv(file.path(raw_dir, "dailyActivity_merged.csv"), show_col_types = FALSE)
activity <- distinct(activity) %>%
  mutate(date = mdy(ActivityDate)) %>%
  select(-ActivityDate)

sleep_day <- read_csv(file.path(raw_dir, "sleepDay_merged.csv"), show_col_types = FALSE)
sleep_day <- distinct(sleep_day) %>%
  mutate(date = as.Date(mdy_hms(SleepDay))) %>%
  select(-SleepDay)

daily_merge <- sleep_day %>%
  inner_join(activity, by = c("Id", "date"))

nrow(activity); nrow(sleep_day); nrow(daily_merge)
head(daily_merge, 3)
```

```
[1] 940
[1] 410
[1] 410

# A tibble: 3 × 18
          Id TotalSleepRecords TotalMinutesAsleep TotalTimeInBed date
       <dbl>             <dbl>              <dbl>          <dbl> <date>
1 1503960366                 1                327            346 2016-04-12
2 1503960366                 2                384            407 2016-04-13
3 1503960366                 1                412            442 2016-04-15
# ℹ 13 more variables: TotalSteps <dbl>, TotalDistance <dbl>, …
```

```r
clean_dir <- "dataset/cleaned_data"
write_csv(daily_merge, file.path(clean_dir, "dailySleepActivity_merged_cleaned.csv"))
```

Weight logs are retained in cleaned form but are **sparse** (few users); primary story uses activity + sleep.

---

## 4. Analyze

Findings below are verified against **this repo’s CSVs** and **`analysis/`** scripts (not the slide deck).

### Sedentary minutes vs minutes asleep (slide 6)
Days with **more minutes asleep** tend to show **fewer sedentary minutes** the same calendar day—the scatter slopes downward.

**Proof:** [`dailySleepActivity_merged_cleaned.csv`](dataset/cleaned_data/dailySleepActivity_merged_cleaned.csv): Pearson **r ≈ -0.601** between `TotalMinutesAsleep` and `SedentaryMinutes`. [`analysis/analysis.R`](analysis/analysis.R) plots the same pair for a quick ggplot check (`assets/dashboard/sleep_vs_sedentary.png`). Figure below exports the chart you built for reporting.

![Sedentary minutes vs total minutes asleep](assets/findings/slide06_sedentary_vs_sleep.png)

---

### Daily activity & sleep summaries (slide 7)
**Daily activity** statistics (steps, distances, intensity minutes, sedentary minutes) and **daily sleep** statistics (`TotalMinutesAsleep`, `TotalTimeInBed`) describe baseline ranges before merging.

**Proof:** [`dailyActivity_cleaned.csv`](dataset/cleaned_data/dailyActivity_cleaned.csv) and [`sleepDay_cleaned.csv`](dataset/cleaned_data/sleepDay_cleaned.csv) from [`clean.R`](analysis/clean.R). Column means match your tables — activity **Mean TotalSteps ≈ 7638**, **Mean SedentaryMinutes ≈ 991.2**; sleep **Mean TotalMinutesAsleep ≈ 419.2**, **Mean TotalTimeInBed ≈ 458.5** (screenshots may round). These summaries use **all** respective daily rows, not only the merged subset.

![Daily activity summary stats](assets/findings/slide07_daily_activity_summary.png)

![Daily sleep summary stats](assets/findings/slide07_daily_sleep_summary.png)

---

### Participant distribution by step bands (slide 8)
Across **distinct users**, **mean daily steps** fall into bands from low to high; distribution is weighted toward moderate counts rather than extremes.

**Proof:** From [`dailyActivity_cleaned.csv`](dataset/cleaned_data/dailyActivity_cleaned.csv): **mean `TotalSteps` per `Id`** (**33** users), bins **&lt; 5k | 5k–7.5k | 7.5k–10k | 10k–12.5k | &gt; 12.5k** → about **24% / 27% / 27% / 15% / 6%**. Any small gap vs a chart tool is rounding or bin-definition choice.

![Participant distribution by activity level](assets/findings/slide08_step_distribution.png)

---

### Hourly intensity, steps, and calories (slide 9)
After expanding hourly files in [`clean.R`](analysis/clean.R), averages by clock hour show low movement overnight, a **midday** bump, and a stronger **early-evening** peak.

**Proof:** [`hourly_pattern_summary.csv`](dataset/cleaned_data/hourly_pattern_summary.csv) from [`analysis.R`](analysis/analysis.R): for each hour, mean `StepTotal`, mean `TotalIntensity`, mean hourly `Calories`. Example **steps** peaks: **18:00** (~599), **19:00** (~583), **17:00** (~550); **12:00–14:00** elevated (~538–548). Hourly **Calories** follow **kcal per clock-hour bucket** as in the Fitbit export.

![Average intensity per hour](assets/findings/slide09_intensity_per_hour.png)

![Average steps per hour](assets/findings/slide09_steps_per_hour.png)

![Average Calories burned per hour](assets/findings/slide09_calories_per_hour.png)

---

### Merged user-days KPI roll-up (`analysis.R` only)
These apply to **[`dailySleepActivity_merged_cleaned.csv`](dataset/cleaned_data/dailySleepActivity_merged_cleaned.csv)** (days with **both** sleep and activity):

| Metric | Value |
|--------|--------|
| Mean daily steps | **~8,515** |
| Mean minutes asleep / night | **~419** (~7.0 h) |
| Mean sedentary minutes / day | **~712** (~11.9 h) |
| Share of merged user-days with &lt; 7,500 steps | **~41%** |
| Share of merged user-days with &lt; 7 h sleep | **~44%** |

Source: [`dataset/cleaned_data/kpi_summary.csv`](dataset/cleaned_data/kpi_summary.csv).

### 📎 Supporting outputs
- [`dataset/cleaned_data/hourly_pattern_summary.csv`](dataset/cleaned_data/hourly_pattern_summary.csv)
- [`dataset/cleaned_data/kpi_summary.csv`](dataset/cleaned_data/kpi_summary.csv)

---

## 5. Share

### 🎬 Presentation
- **[Open slides on Canva](https://canva.link/emsulvwxmh7dtii)** (same design as your deck; use **Share → Anyone with the link** in Canva if viewers can’t open it).

### 🔁 How to reproduce figures and tables
From the project root (with R packages installed, e.g. `dplyr`, `tidyr`, `lubridate`, `readr`, `ggplot2`):

```bash
Rscript analysis/clean.R
Rscript analysis/analysis.R
```

---

## 6. Act

Recommendations below follow the **findings in §4** (segment, features, and channels).

### 📱 Product and experience (Bellabeat app–oriented)
- **Audience:** people who care about **sleep quality** and sustainable daily movement.
- **Sleep:** wind-down content (e.g. short meditation or light stretching before bed); consider richer **sleep insight** in-app when data allows (duration breakdown, consistency).
- **Movement:** **streaks / rewards** for hitting step goals; **mid-day nudges** aligned with low activity during typical work hours and peaks around lunch and early evening.
- **Sedentary breaks:** gentle prompts after long inactive stretches.

### 📣 Marketing
- Emphasize **sleep + energy** and realistic activity goals (not only “10k steps”).
- **Short-form social** (e.g. TikTok) and **creator partnerships** in the fitness/wellness space.

### 🔭 Next data steps
- Larger, more representative sample; Bellabeat first-party app data where available; longer time windows to validate seasonality.

---

## About me

I’m **Iris Huynh**, a data analytics learner focused on **turning behavioral and health-related data into clear, actionable stories** for product and marketing decisions. This repository is my **Google Data Analytics capstone** (Bellabeat case study): data prep and analysis in **R**, structured around the **Ask → Act** process, with a **Canva** deck for stakeholders.

- **Focus areas:** data cleaning, exploratory analysis, visualization, and communication of recommendations.  
- **This project:** Fitbit-based smart-device usage patterns, sleep and activity insights, and ideas for the Bellabeat app and go-to-market story.  
- **Connect:** [GitHub profile](https://github.com/irishuynh23). Add your LinkedIn, portfolio, or email on this line when you’re ready.

---

## 🛠️ Tools
- **R**: `dplyr`, `tidyr`, `lubridate`, `readr`, `ggplot2`
- **Docs**: course case brief (PDF), presentation PDF + **Canva** slides

---

## ⚖️ License and attribution
- Fitbit Fitness Tracker Data is used here under **CC0** as described on Kaggle and in course materials.
- Bellabeat is a trademark of its owner; this is an **educational case study**, not affiliated with Bellabeat.
