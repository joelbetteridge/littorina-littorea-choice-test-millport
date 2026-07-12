<img width="638" height="581" alt="image" src="https://github.com/user-attachments/assets/40ae47e9-fec3-4cfe-8ec5-45c74aa25f27" />
<img width="697" height="581" alt="image" src="https://github.com/user-attachments/assets/e89cbec3-66b0-4318-a010-ed56fb354095" />

# Flat Periwinkle (*Littorina littorea*) Choice Test Analysis

R script for statistical analysis and figure generation from a two-treatment choice test examining behavioural responses of flat periwinkles to beadlet anemones (*Actinia equina*).

---

## Study Overview

All data were collected on the island of Millport (Scotland) by Joel Betteridge, Anne Strevens and William Grimsdell.
This experiment tested whether *L. littorea* would avoid *A. equina* in a controlled choice test. Five snails were placed in a glass tank containing either real beadlet anemones (anemone treatment) or water only (control). Snail positions were scored at 10-minute intervals over 30 minutes using a positional scoring system (see below).

**Scoring system:**

| Zone | Score (per snail) |
|---|---|
| Closest third to real anemones | -1 |
| Central third | 0 |
| Closest third to plastic anemones | +1 |

Scores were summed across all five snails per trial (range: -5 to +5). A negative sum score indicates movement towards real anemones.

---

## Repository Structure

```
project/
├── data-raw/
│   ├── snails.xlsx          # Full time-series data (10, 20, 30 min intervals)
│   └── snails_summary.xlsx  # Final 30-min score per trial
├── snail_analysis.R         # Main analysis script
├── figure1_30min_scores.png # Output: boxplot of 30-min scores
├── figure2_time_course.png  # Output: time-course line graph
└── README.md
```

---

## Requirements

**R version:** 4.0 or higher

**Packages:**
```r
install.packages(c("ggplot2", "dplyr", "tidyverse", "readxl"))
```

---

## Usage

1. Clone the repository and open in RStudio
2. Place your data files in `data-raw/`
3. Run `snail_analysis.R` from top to bottom
4. Figures are saved as 300 dpi PNGs in the working directory

---

## Statistical Approach

All tests are non-parametric, appropriate for the bounded ordinal score (-5 to +5).

| Test | Purpose |
|---|---|
| One-sample Wilcoxon signed-rank | Tests whether each treatment's median score differs from zero (no preference) |
| Two-sample Wilcoxon rank-sum (Mann-Whitney U) | Tests whether the two treatments differ significantly from each other at 30 min |
| Kruskal-Wallis | Tests whether scores change significantly across time points (10, 20, 30 min) within each treatment |

---

## Outputs

**Figure 1** — Boxplot with jittered raw data points showing sum scores at 30 minutes for each treatment. Significance bracket annotated with Mann-Whitney U p-value.

**Figure 2** — Line graph of mean ± SE sum score at 10, 20, and 30 minutes for each treatment, with shaded SE ribbons.

---

## Data Format

`snails.xlsx` should contain three columns:

| Column | Description |
|---|---|
| `Treatment` | `c+v` (anemone treatment) or `control` |
| `Time` | Time point in minutes: `10`, `20`, or `30` |
| `Count` | Sum score for that trial at that time point |

`snails_summary.xlsx` should contain two columns:

| Column | Description |
|---|---|
| `Treatment` | `c+v` or `control` |
| `Count` | Final 30-min sum score for that trial |

---
