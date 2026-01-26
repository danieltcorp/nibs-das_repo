################################################################################
# R Script Title: NIBS-DAS_mep_da_R_2025-12-11.R
#
# Demonstrates tidyverse-style data analysis for a fictional neurophysiological NIBS dataset: 
# "NIBS-DAS_mep_exampledata_2025-12-11_copy.xlsx" / "NIBS-DAS_mep_exampledata_2025-12-11_copy.tsv"
#
# Demonstrates example analyses which:
# (i) measure MEP amplitudes in different muscles (FDI, APB) using linear regression
# (ii) compare MEP amplitudes between muscles using mixed effects models.

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

# ********************************************************************************
# SET ROOT DIRECTORY
# ********************************************************************************

# Set root directory
#root <- "[YourFilePath]/NIBS-DAS_mep_example/collated_participant_data"
root <- "C:/Users/barham/OneDrive - Deakin University/Desktop/Research/Big NIBS Data/Projects/2025_NIBS-DAS/NIBS-DAS_examples/2025-12-11/NIBS-DAS_mep_example/collated_participant_data"
setwd(root)

# Create directories (if needed)
dir.create(file.path(root, "outputfiles"), showWarnings = FALSE)

# Start simple text log
log_file <- file.path(root, "outputfiles", "NIBS-DAS_mep_da_log_R_2025-12-11.txt")
  sink(log_file, split = TRUE)
on.exit(sink(NULL)) # Ensure log closes even if errors occur

# ********************************************************************************
# EXAMPLE A - ANALYSIS OF MEAN BLOCK MEP AMPLITUDES
# ********************************************************************************
# Analyses can be performed on datasets where the mean / average MEP amplitude has been computed across blocks of TMS pulses, 
# as per the following code.

# Open file
mep_mean_wide <- read_csv(file.path(root, "usedata", "NIBS-DAS_mep_exampledata_meanblock_wide_2025-12-11.csv")) # Import 'wide' format dataset. Assign the .csv to a dataframe

# Reorder your categorical variable as a factor (for interpretation / plotting)
mep_mean_wide$trial_type <- factor(mep_mean_wide$trial_type, levels = c("Unconditioned", "Conditioned"))

# MEP Example Question 1: are mean block MEP amplitudes in the FDI muscle significantly predicted by trial type, age and sex?
model1 <- lm(mean_fdi_mep_ampl ~ trial_type + age + sex, data = mep_mean_wide, REML = FALSE)
summary(model1)
emmeans(model1, ~ trial_type) # Show marginal means for each level of IVs included in the model

# Generate and save plot
plot1 <- sjPlot::plot_model(model1, type = 'emm', terms = c('trial_type')) + 
  ggtitle("Analysis of MEP amplitude (mV) in FDI muscle") + 
  ylab("MEP amplitude (mV): FDI") + xlab("Type of MEP") + 
  geom_line() + 
  theme_bw()
plot1 # View plot
ggsave(file.path(root,"outputfiles", "NIBS-DAS_mep_question1_figure_R_2025-12-11.tif"), plot1, width = 6, height = 4, dpi = 300) # Save plot


# MEP Example Question 2: are mean block MEP amplitudes in the APB muscle significantly predicted by trial type, age and sex?
model2 <- lm(mean_apb_mep_ampl ~ trial_type + age + sex, data = mep_mean_wide, REML = FALSE)
summary(model2)
emmeans(model2, ~ trial_type)

# Generate and save plot
plot2 <- sjPlot::plot_model(model2, type = 'emm', terms = c('trial_type')) + 
  ggtitle("Analysis of MEP amplitude (mV) in APB muscle") + 
  ylab("MEP amplitude (mV): APB") + xlab("Type of MEP") + 
  geom_line() + 
  theme_bw()
plot2
ggsave(file.path(root,"outputfiles", "NIBS-DAS_mep_question2_figure_R_2025-12-11.tif"), plot2, width = 6, height = 4, dpi = 300) 


# ********************************************************************************
# EXAMPLE B - ANALYSIS OF MEP AMPLITUDE BETWEEN MUSCLES
# ********************************************************************************
# To analyse MEP values by muscle, need to have data in 'long-long' format. Using the dataset previously reshaped into this layout,
# we can now include 'muscle' as the IV in the analyses. For example:

# Open file
mep_mean_long <- read_csv(file.path(root, "usedata", "NIBS-DAS_MEP_exampledata_meanblock_long_2025-12-11.csv")) # Import 'long-long' format dataset. Assign the .csv to a dataframe

# Reorder your categorical variables as a factor
mep_mean_long$trial_type <- factor(mep_mean_long$trial_type, levels = c("Unconditioned", "Conditioned"))

# MEP Example Question 3: Is there a significant difference in MEP amplitudes in FDI and APB muscles 
# between conditioned and unconditioned TMS trials, adjusting for age and sex?

model3 <- lmer(MEPampl ~ age + sex + trial_type + muscle + trial_type*muscle + (1|participant_id),
               data = mep_mean_long,
               REML = FALSE)
summary(model3)
contrast(emmeans(model3, ~ trial_type*muscle), interaction = 'pairwise') # Significance of overall interaction effect.
emmeans(model3, ~ trial_type)
emmeans(model3, ~ trial_type*muscle) # Show marginal means for each level of interaction between MEP type and muscle

# Get estimated marginal means
emm3 <- emmeans(model3, ~ trial_type * muscle)

# Convert to data frame for plotting
emm3_df <- as.data.frame(emm3)

# Generate and save plot
plot3 <- ggplot(emm3_df, aes(x = trial_type, y = emmean, colour = muscle, group = muscle)) + 
  geom_point(size = 3) + 
  geom_line() + 
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) +
  labs(title = "Comparison of MEP amplitudes in FDI and APB muscles", y = "MEP amplitude (mV)", x = "Trial type") + 
  theme_bw()
plot3
ggsave(file.path(root,"outputfiles", "NIBS-DAS_mep_question3_figure_R_2025-12-11.tif"), plot3, width = 6, height = 4, dpi = 300)


# ********************************************************************************
# * NOTE ON COLLAPSED VS UNCOLLAPSED MEP DATA 
# ********************************************************************************
# Analyses of collapsed data cannot account for within subject variance in data. Analyses examining variance in inter-individual response to NIBS will 
# require analysing unaveraged MEP data, for example, the format used in the "NIBS-DAS_mep_exampledata_uncollapsed_wide_2025-12-11.csv" datafile.

# When using all MEPs in your analysis one should think carefully about the nesting structure of the data. For example, in an experiment where MEPs are 
# collected within separate blocks over time (i.e., not randomised within the same MEP block), it may be appropriate to also nest the MEPs within these 
# separate MEP blocks. The 'mep_block' variable created for datafile "NIBS-DAS_mep_exampledata_mep-block_2025-12-11.csv" could be used as an IV to account 
# for nesting within blocks of MEPs in such an analysis.

#For further reading see:
#  https://doi.org/10.1371/journal.pone.0146721 and https://doi.org/10.3389/fpsyg.2015.01171


################################################################################

sink(NULL) # Close log 

################################################################################
# END OF SCRIPT
################################################################################