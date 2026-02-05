################################################################################
# R Script Title: nibs-das_mep_da_r_2026-02-04.R
#
# R code demonstrating tidyverse-style data analysis (da) for a fictional neurophysiological (e.g., TMS MEP) NIBS dataset: 
# "nibs-das_mep_exampledata_2026-02-04_copy.xlsx".
#
# Dataset prepared for analyses performed in the corresponding data management code file: 
# "nibs-das_mep_dm_stata_2026-02-04.R"
#
# Demonstrates example analyses which:
# (i) measure MEP amplitudes in different muscles (FDI, APB)
# (ii) compare SICI between muscles using mixed effects models

################################################################################

# ********************************************************************************
#   * LOAD LIBRARIES *
# ********************************************************************************

library(tidyverse)
library(emmeans)
library(lme4)
library(sjPlot)
library(lmerTest)
library(ggplot2)
library(ggsignif)
library(broom.mixed)


# ********************************************************************************
# EXAMPLE A - ANALYSIS OF SICI IN FDI AND APB MUSCLES SEPARATELY
# ********************************************************************************

# Set your working directory
dir <- "[YourFilePath]/nibs-das_examples/mep_example/collated_participant_data"
setwd(dir)

# This analysis requires a dataset layout where MEPs from FDI and APB muscles are separate variables.

# Open file
mep_mean_wide <- read_csv("usedata/nibs-das_mep_exampledata_blockmean.csv") # Assign the .csv to a dataframe

# Reorder your categorical variable/s as a factor (for interpretation / plotting)
mep_mean_wide$tms_stim_mode <- factor(mep_mean_wide$tms_stim_mode, levels = c("single", "dual"))

# MEP Example A1: Is SICI present in the FDI muscle, adjusting for age, sex, and pre-stimulus EMG activity?
model1 <- lmer(mep_ampl_fdi ~ tms_stim_mode + age + sex + pre_rms_fdi + (1|participant_id), 
               data = mep_mean_wide, REML = FALSE)
tidy(model1, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model1, type = 3)["tms_stim_mode", , drop = FALSE] # Significance of main effect of trial type 
emmeans(model1, ~ tms_stim_mode) # Show marginal means for each level of trial type (single; dual)
  emm1 <- emmeans(model1, ~ tms_stim_mode) 
  emm1_df <- as.data.frame(emm1) # Convert marginal means to data frame for plotting

# Generate plot of estimated marginal means
plot1 <- ggplot(emm1_df, aes(x = tms_stim_mode, y = emmean)) +
    ggtitle("Analysis of SICI in FDI muscle") + xlab("Type of MEP") + ylab("MEP amplitude (mV): FDI") + 
    geom_point(size = 3) + geom_line(aes(group = 1)) + # Points and lines
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.05) + # Error bars
    scale_y_continuous(limits = c(0, 1.2), breaks = seq(0, 1.2, 0.2)) + scale_x_discrete(expand = expansion(add = 0.1)) + # Axis scales
    theme_bw() + # Theme settings
      theme(plot.title = element_text(hjust = 0.5))  # Center-align title
plot1 # View plot


# MEP Example A2: Is SICI present in the APB muscle, adjusting for age and sex, and pre-stimulus EMG activity? 
model2 <- lmer(mep_ampl_apb ~ tms_stim_mode + age + sex + pre_rms_apb + (1|participant_id), 
               data = mep_mean_wide, REML = FALSE)
tidy(model2, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model2, type = 3)["tms_stim_mode", , drop = FALSE]
emmeans(model2, ~ tms_stim_mode) 
  emm2 <- emmeans(model2, ~ tms_stim_mode) 
  emm2_df <- as.data.frame(emm2)

# Generate plot of estimated marginal means
plot2 <- ggplot(emm2_df, aes(tms_stim_mode, emmean)) +
  ggtitle("Analysis of SICI in APB muscle") + ylab("MEP amplitude (mV): APB") + xlab("Type of MEP") + 
  geom_point(size = 3) + geom_line(aes(group = 1)) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = .05) + 
  scale_y_continuous(limits = c(0, 1.2), breaks = seq(0, 1.2, 0.2)) + scale_x_discrete(expand = expansion(add = 0.1)) +
  theme_bw() + 
    theme(plot.title = element_text(hjust = 0.5)) 
plot2 # View plot


# ********************************************************************************
# EXAMPLE B - ANALYSIS OF SICI BETWEEN FDI AND APB MUSCLES
# ********************************************************************************
# To analyse SICI by muscle, need to have data in a 'long' format containing a variable denoting which muscle each MEP was measured from. 
# Using the dataset previously reshaped into this layout, we can now include 'muscle' as an IV in the analyses. For example: 

# Open file
mep_mean_long <- read_csv("usedata/nibs-das_MEP_exampledata_blockmean_long.csv")

# Reorder your categorical variable/s as a factor
mep_mean_long$tms_stim_mode <- factor(mep_mean_long$tms_stim_mode, levels = c("single", "dual"))
mep_mean_long$muscle <- factor(mep_mean_long$muscle, levels = c("FDI", "APB"))

# MEP Example B: Is there a difference in SICI between FDI and APB muscles, adjusting for age, sex, and pre-stimulus EMG activity?
model3 <- lmer(mep_ampl ~ age + sex + pre_rms + tms_stim_mode*muscle + (1|participant_id),
               data = mep_mean_long, REML = FALSE)
tidy(model3, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model3, type = 3)["tms_stim_mode:muscle", , drop = FALSE] 
emmeans(model3, ~ tms_stim_mode*muscle) # Show marginal means for each level of interaction between trial type and muscle
  emm3 <- emmeans(model3, ~ tms_stim_mode * muscle)
  emm3_df <- as.data.frame(emm3) # Convert marginal means to data frame for plotting
  
# Generate and save plot of estimated marginal means
plot3 <- ggplot(emm3_df, aes(x = tms_stim_mode, y = emmean, colour = muscle, group = muscle)) + 
  geom_point(size = 3) + geom_line() + geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.025) +
  scale_colour_manual(values = c("FDI" = "skyblue2", "APB" = "maroon")) + 
  labs(title = "Comparison of SICI in FDI and APB muscles", y = "MEP amplitude (mV)", x = "Trial type") + 
  scale_y_continuous(limits = c(0.35, 1.2), breaks = seq(0.4, 1.2, 0.2)) + scale_x_discrete(expand = expansion(add = 0.1)) +
  theme_bw() + theme(plot.title = element_text(hjust = 0.5))
plot3 # View plot
ggsave(file.path(dir,"outputfiles/nibs-das_mep_questionB_figure_r.png"), plot3, width = 6, height = 4, dpi = 300)


################################################################################
# END OF SCRIPT
################################################################################

# (OPTIONAL) The following code produces Figure 5 from the companion NIBS-DAS manuscript.

# Generate Example B figure for publication
plot4 <- ggplot(emm3_df, aes(x = tms_stim_mode, y = emmean, colour = muscle, group = muscle)) +
  geom_point(size = 3, position = position_dodge(width = 0.035)) + geom_line(linewidth = 1, position = position_dodge(width = 0.035)) +   # Add points and lines
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1, position = position_dodge(width = 0.035)) + # Add error bars
  scale_colour_manual(values = c("FDI" = "#AFD7DF", "APB" = "#E096C6")) +   # Specify colours for each muscle using HEX codes
  scale_x_discrete(labels = c("single" = "Single Pulse\n(Unconditioned)","dual"   = "Dual Pulse\n(Conditioned)"), # Label X-axis
    expand = expansion(mult = 0.25)) + # Customise X-axis scale
  scale_y_continuous(limits = c(0.35, 1.2), breaks = seq(0.4,1.2, by = 0.2)) + # Customize Y-axis scale
  geom_signif(  
    xmin = 1, xmax = 2,
    annotations = "***", 
    y_position = max(emm3_df$upper.CL) * 1.05, 
    tip_length = 0.02, 
    colour = "grey") +# Add significance annotation
  labs(title = "", y = "MEP amplitude (mV)", x = "Type of MEP", colour = "Muscle") + # Add labels and titles
  theme_bw() + # Apply theme
  theme(
    panel.grid = element_blank(), # Remove grid lines
    panel.border = element_blank(), # Remove borders
    axis.line = element_line(colour = "black")  # Add bottom and left axes; colour black
  )
plot4 # View plot
ggsave(file.path(dir, "outputfiles/nibs-das_mep_questionB_figure_r_publication.tif"), plot4, width = 6, height = 4, dpi = 300) # Save plot