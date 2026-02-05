###############################################################################
# R Script Title: nibs-das_clinical_da_r_2026-02-04.R
#
# R code demonstrating tidyverse-style data analysis (da) of a fictional clinical NIBS dataset:
# "nibs-das_clinical_exampledata_2026-02-04.xlsx".
#
# Dataset prepared for these analyses using the corresponding data management (dm) code file: 
# "nibs-das_clinical_dm_stata_2026-02-04.R"
#
# Demonstrates example analyses which:
# (i) compare clinical symptom scores between active and sham NIBS conditions
# (ii) compare clinical symptoms scores between active and sham NIBS conditions using a symptom change percentage
# (iii) analyse a combined, multi-study ('big') dataset

###############################################################################

# ********************************************************************************
#   * LOAD LIBRARIES *
# ********************************************************************************

library(tidyverse)    
library(lme4)         
library(lmerTest)     
library(emmeans)      
library(psych)        
library(readxl)       
library(summarytools) 
library(margins)      
library(ggeffects)
library(ggsignif)
library(broom.mixed)


# ********************************************************************************
# EXAMPLE A – ANALYSIS OF SYMPTOM SCORES BETWEEN CONDITIONS
# ********************************************************************************

# Set your working directory
dir <- "C:/[YourFilePath]/nibs-das_examples/clinical_example/collated_participant_data"
setwd(dir) 

# Analyse the effect of active and sham NIBS conditions on symptom scores over time. This requires a 'long' dataset layout.

# Open data
clinical_long <- read_csv("usedata/nibs-das_clinical_exampledata_long.csv") # Assign the .csv to a dataframe

# Reorder your categorical variable/s as a factor (for interpretation / plotting)
clinical_long$session_id <- factor(clinical_long$session_id, levels = c("ses-pre", "ses-post1"))
clinical_long$sex <- factor(clinical_long$sex, levels = c("Female", "Male"))
clinical_long$group <- factor(clinical_long$group, levels = c("Sham", "Real"))

# Clinical Example A1: Is there a difference in symptom scores over time between active and sham NIBS conditions, adjusting for age and sex?
model1 <- lmer(symptom_score_madrs ~ age + sex + session_id*group + (1|participant_id), 
               data = clinical_long, REML = FALSE)
tidy(model1, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model1, type = 3) ["session_id:group", , drop = FALSE] # Significance of overall interaction effect. 
emmeans(model1, ~ session_id * group) # Show marginal means for each level of interaction between session_id and group
  emm1 <- emmeans(model1, ~ session_id * group) 
  emm1_df <- as.data.frame(emm1) # Convert marginal means to data frame for plotting

# Generate and save graph
plot1 = ggplot(emm1_df, aes(x = session_id, y = emmean, colour = group, group = group)) + 
  geom_point(size = 3) + geom_line(linewidth = 1) + geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) + 
  scale_colour_manual(values = c("Sham" = "skyblue2", "Real" = "maroon")) + 
  scale_x_discrete(labels = c("Pre", "Post1")) + 
  theme_bw() + 
  labs(title = "", x = "Session", y = "MADRS symptom score", colour = "Group" )
plot1 # Generate graph
ggsave(file.path(dir,"outputfiles", "nibs-das_clinical_questionA1_figure_r.png"), plot1, width = 6, height = 4, dpi = 300) # Export graph


# You may also want to analyse the effect of the rTMS using symptom change percentage as the dependent variable. 
# Here, we can call the "wide" dataset and use standard linear multiple regression. 

# Open data
clinical_wide <- read_csv("usedata/nibs-das_clinical_exampledata_wide.csv") # Import 'wide' dataset containing a symptom percentage change ('pct_change') variable. Assign to a dataframe

# Reorder your categorical variables as a factor
clinical_wide$sex <- factor(clinical_wide$sex, levels = c("Female", "Male"))
clinical_wide$group <- factor(clinical_wide$group, levels = c("Sham", "Real"))

# Clinical Example A2: Is there a significant symptom score improvement over time between active and sham NIBS conditions, adjusting for age and sex?
model2 <- lm(pct_change ~ age + sex + group, data = clinical_wide)
tidy(model2, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model2, type = 3)["group", , drop = FALSE]
emmeans(model2, ~ group) 
  emm2 <- emmeans(model2, ~ group) 
  emm2_df <- as.data.frame(emm2)

# Generate and save graph
plot2 = ggplot(emm2_df, aes(x = group, y = emmean, colour = group, group = group)) + 
  geom_point(size = 3) + geom_line(linewidth = 1) + geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) + 
  scale_x_discrete(labels = c("Sham", "Real")) + 
  theme_bw() + 
  labs(title = "", x = "Session", y = "MADRS symptom percentage change score", colour = "Group" )
plot2 # Generate graph
ggsave(file.path(dir,"outputfiles", "nibs-das_clinical_questionA2_figure_r.png"), plot2, width = 6, height = 4, dpi = 300) # Export graph
  

# ********************************************************************************
# EXAMPLE B – ANALYSIS OF SYMPTOM SCORES ACROSS MULTIPLE CLINICAL TRIALS *
# ********************************************************************************
# You can perform analyses of data combined from multiple studies (i.e., 'big data' analyses) using an appended dataset.

# Open data
combined_data <- read_csv(file.path(dir,"usedata","nibs-das_clinical_exampledata_combined.csv")) # Import 'appended' dataset containing data combined from multiple studies

# Reorder your categorical variable/s as a factor (for interpretation / plotting)
combined_data$session_id <- factor(combined_data$session_id, levels = c("ses-pre", "ses-post1"))
combined_data$sex <- factor(combined_data$sex, levels = c("Female", "Male"))
combined_data$group <- factor(combined_data$group, levels = c("Sham", "Real"))

# Clinical Example B: Is there a difference in symptom scores over time between active and sham NIBS conditions, adjusting for age and sex, across studies? 
model3 <- lmer(symptom_score_madrs ~ age + sex + study_id + session_id + group + session_id*group + (1|study_participant_id), 
               data = combined_data, REML = FALSE)
tidy(model3, effects = "fixed", conf.int = TRUE, conf.method = "Wald")
car::Anova(model3, type = 3) ["session_id:group", , drop = FALSE] # Significance of overall interaction effect. 
emmeans(model3, ~ session_id * group) # Show marginal means for each level of interaction between session_id and group
  emm3 <- emmeans(model3, ~ session_id * group, weights = "equal", cov.reduce = mean) # Show marginal means for each level of interaction between session_id and group
  emm3_df <- as.data.frame(emm3) # Convert marginal means to data frame for plotting

# Generate and export plot
plot3 = ggplot(emm3_df, aes(session_id, emmean, colour = group, group = group)) +
  geom_point(size = 3) + geom_line(linewidth = 1) +
  scale_colour_manual(values = c("Sham" = "skyblue2", "Real" = "maroon")) + 
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) +
  scale_x_discrete(labels = c("Pre", "Post1")) +
  theme_bw() +
  labs(x = "Session", y = "MADRS symptom score", colour = "Group")
plot3
ggsave(file.path(dir,"outputfiles", "nibs-das_clinical_questionB_figure_r.png"), plot3, width = 6, height = 4, dpi = 300) # Export graph

# Note: The above analysis is a mixed model with unique identifier study_participant_id as random factor. Here, study_id is a fixed 
# effect because the number of combined studies is low. Where a greater number of studies are combined, study_id can be a random factor.


################################################################################
# END OF SCRIPT
################################################################################


# (OPTIONAL) The following code produces Figure 4 from the companion NIBS-DAS manuscript.

# Generate Example Question A1 figure for publication
plot4 <- ggplot(emm1_df, aes(x = session_id, y = emmean, colour = group, group = group)) +
  geom_point(size = 3, position = position_dodge(width = 0.035)) + geom_line(linewidth = 1, position = position_dodge(width = 0.035)) + # Add points and lines
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1, position = position_dodge(width = 0.035)) + # Add error bars
  scale_colour_manual(values = c("Sham" = "#AFD7DF", "Real" = "#E096C6")) + # Specify colours for each group using HEX codes
  scale_x_discrete(labels = c("Pre", "Post1"), expand = expansion(mult = 0.2)) + # Customise X-axis scale
  geom_signif(
    comparisons = list(c("ses-pre", "ses-post1")),
    annotations = "***",
    y_position = max(emm1_df$upper.CL) + 1,
    tip_length = 0.02,
    colour = "grey"
  ) + # Add significance annotation
  labs(title = "", y = "MADRS symptom score", x = "Session", colour = "Group") +  # Add labels and titles
  theme_bw() +  # Apply theme
  theme(
    panel.grid = element_blank(), # Remove grid lines
    panel.border = element_blank(), # Remove borders
    axis.line = element_line(colour = "black") # Add bottom and left axes; colour black
  )
plot4  # View plot
ggsave(file.path(dir, "outputfiles", "nibs-das_clinical_questionA1_figure_r_publication.tif"), plot4, width = 6, height = 4, dpi = 300) # Save plot