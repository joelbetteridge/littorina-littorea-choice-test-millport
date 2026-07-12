# Flat Periwinkle Choice Test Analysis -----------------------------------------
# Treatments: c+v (control + visual / real anemones) vs control (water only)
# Score: -1 = anemone side, 0 = centre, +1 = plastic anemone side (summed across
# 5 snails: range -5 to +5)


# Load packages ----------------------------------------------------------------

library(ggplot2)

library(dplyr)

library(tidyverse)

library(readxl)

# Load data and edit -----------------------------------------------------------

df_time <- read_excel("data-raw/snails.xlsx")

df_summary <- read_excel("data-raw/snails_summary.xlsx")

# Label treatments clearly
df_time$Treatment    <- factor(df_time$Treatment,
                               levels = c("c+v", "control"),
                               labels = c("Anemones", "Control"))
df_summary$Treatment <- factor(df_summary$Treatment,
                               levels = c("c+v", "control"),
                               labels = c("Anemones", "Control"))

# Statistical Analysis ---------------------------------------------------------

# Final 30-min scores: are they different from zero?
# A score < 0 means snails are on the anemone side.
# Test each treatment against 0 with a one-sample Wilcoxon signed-rank test
# (non-parametric; scores are ordinal/bounded).

cv_30      <- df_summary$Count[df_summary$Treatment == "Anemones"]
control_30 <- df_summary$Count[df_summary$Treatment == "Control"]

w_cv <- wilcox.test(cv_30, mu = 0, alternative = "two.sided", exact = FALSE)
cat("Real anemones treatment:\n")
print(w_cv)

w_ctrl <- wilcox.test(control_30, mu = 0, alternative = "two.sided", exact = FALSE)
cat("Control treatment:\n")
print(w_ctrl)

# Do the two treatments differ from each other at 30 min?
w_between <- wilcox.test(cv_30, control_30, alternative = "two.sided", exact = FALSE)
print(w_between)

# Time-course: do scores change over time within each treatment?
# Friedman test (repeated-measures non-parametric) or Kruskal-Wallis per treatment.
# Use Kruskal-Wallis (independent groups per time point across trials).

cv_time <- df_time[df_time$Treatment == "Anemones", ]
kw_cv   <- kruskal.test(Count ~ factor(Time), data = cv_time)
print(kw_cv)

ctrl_time <- df_time[df_time$Treatment == "Control", ]
kw_ctrl   <- kruskal.test(Count ~ factor(Time), data = ctrl_time)
print(kw_ctrl)

# Descriptive summaries

desc_summary <- df_summary %>%
  group_by(Treatment) %>%
  summarise(
    n      = n(),
    mean   = round(mean(Count), 2),
    median = median(Count),
    sd     = round(sd(Count), 2),
    se     = round(sd(Count) / sqrt(n()), 2),
    .groups = "drop"
  )
print(desc_summary)

desc_time <- df_time %>%
  group_by(Treatment, Time) %>%
  summarise(
    n      = n(),
    mean   = round(mean(Count), 2),
    median = median(Count),
    sd     = round(sd(Count), 2),
    se     = round(sd(Count) / sqrt(n()), 2),
    .groups = "drop"
  )
print(desc_time)

# Figure 1: Final 30-min scores per treatment (box + jitter) -------------------

# Significance annotation for Figure 1
# w_between p-value for annotation
p_between <- w_between$p.value
sig_label  <- ifelse(p_between < 0.001, "***",
                     ifelse(p_between < 0.01,  "**",
                            ifelse(p_between < 0.05, "*", "ns")))

fig1 <- ggplot(df_summary, aes(x = Treatment, y = Count, fill = Treatment)) +
  # Reference line at zero
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50", linewidth = 0.6) +
  # Boxplot
  geom_boxplot(width = 0.45, outlier.shape = NA, alpha = 0.7, colour = "grey30") +
  # Raw data overlay
  geom_jitter(width = 0.12, size = 2.2, alpha = 0.8, colour = "grey20") +
  # Significance bracket
  annotate("segment",
           x = 1, xend = 2, y = 4.2, yend = 4.2,
           colour = "black", linewidth = 0.7) +
  annotate("segment", x = 1, xend = 1, y = 4.0, yend = 4.2,
           colour = "black", linewidth = 0.7) +
  annotate("segment", x = 2, xend = 2, y = 4.0, yend = 4.2,
           colour = "black", linewidth = 0.7) +
  annotate("text", x = 1.5, y = 4.55,
           label = paste0("p = ", round(p_between, 3), " (", sig_label, ")"),
           size = 3.5) +
  scale_fill_manual(values = c("Anemones" = "#CC79A7",
                               "Control"        = "#0072B2")) +
  scale_y_continuous(breaks = seq(-5, 5, 1), limits = c(-5.5, 5)) +
  labs(
    x = "Treatment",
    y = "Sum score at 30 min (5 snails)",
  ) +
  theme_classic(base_size = 13) +
  theme(
    legend.position  = "none",
    plot.title       = element_text(face = "bold", size = 13),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    axis.title       = element_text(size = 12),
    axis.text        = element_text(size = 11)
  )
fig1

ggsave("figure1_30min_scores.png", fig1,
       width = 5.5, height = 5, dpi = 300, bg = "white")
cat("\nFigure 1 saved: figure1_30min_scores.png\n")


# 4. Figure 2: Score over time (mean ± SE) for each treatment ------------------

fig2 <- ggplot(desc_time,
               aes(x = Time, y = mean,
                   colour = Treatment, fill = Treatment,
                   group = Treatment)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50", linewidth = 0.6) +
  # Ribbon for ±1 SE
  geom_ribbon(aes(ymin = mean - se, ymax = mean + se),
              alpha = 0.20, colour = NA) +
  # Line
  geom_line(linewidth = 1.1) +
  # Points
  geom_point(size = 3.5, shape = 21, colour = "grey20",
             aes(fill = Treatment)) +
  scale_colour_manual(values = c("Anemones" = "#CC79A7",
                                 "Control"        = "#0072B2")) +
  scale_fill_manual(values   = c("Anemones" = "#CC79A7",
                                 "Control"        = "#0072B2")) +
  scale_x_continuous(breaks = c(10, 20, 30)) +
  scale_y_continuous(breaks = seq(-3, 2, 1)) +
  labs(
    x      = "Time (minutes)",
    y      = "Mean sum score (5 snails) ± SE",
    colour = "Treatment",
    fill   = "Treatment",
  ) +
  theme_classic(base_size = 13) +
  theme(
    legend.position  = c(0.87, 0.92),
    legend.background = element_rect(colour = "grey80", fill = "white"),
  )
fig2

ggsave("figure2_time_course.png", fig2,
       width = 6, height = 5, dpi = 300, bg = "white")
