###############################################################################
# R Script Title: NIBS-DAS_clinical_da_R_2025-12-11.R
#
# Demonstrates tidyverse-style data analysis (da) of a fictional clinical NIBS dataset:
# "NIBS-DAS_clinical_exampledata_2025-12-11.xlsx" / "NIBS-DAS_clinical_exampledata_2025-12-11_copy.tsv"
#
# Demonstrates example analyses which:
# (i) compare clinical symptom scores between NIBS conditions (e.g., active versus sham)
# (ii) analyse a combined, multi-study ('big') dataset

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

# ********************************************************************************
#   * SET ROOT DIRECTORY *
# ********************************************************************************

# Set root directory
#root <- "C:/[YourFilePath]/NIBS-DAS_clinical_example/collated_participant_data"
root <- "C:/Users/barham/OneDrive - Deakin University/Desktop/Research/Big NIBS Data/Projects/2025_NIBS-DAS/NIBS-DAS_examples/2025-12-11/NIBS-DAS_clinical_example/collated_participant_data"
setwd(root) 

# Create directories (if needed)
dir.create(file.path(root, "outputfiles"), showWarnings = FALSE)

# Start log
log_file <- file.path(root, "outputfiles", "NIBS-DAS_clinical_da_log_R_2025-12-11.txt")
  sink(log_file, split = TRUE)
on.exit(sink(NULL), add = TRUE) # Ensure log closes even if errors occur

# ********************************************************************************
# EXAMPLE A – ANALYSIS OF SYMPTOM SCORES BETWEEN CONDITIONS
# ********************************************************************************

# Open data
clinical_long <- read_csv(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_long_2025-12-11.csv")) # Open 'long' format data. Assign the .csv to a dataframe

# Reorder your categorical variables as a factor (for interpretation / plotting)
clinical_long$timepoint <- factor(clinical_long$timepoint, levels = c("Pre", "Post1"))
clinical_long$sex <- factor(clinical_long$sex, levels = c("Male", "Female"))
clinical_long$group <- factor(clinical_long$group, levels = c("Sham", "Real"))

# Clinical Question 1:
# Is there a significant difference in pre vs post symptom scores between active and sham NIBS,
# adjusting for age and sex?

model_1 <- lmer(symptom_score_madrs ~ age + sex + timepoint + group + timepoint*group + (1|participant_id),
                data = clinical_long,
                REML = FALSE)
summary(model_1)
contrast(emmeans(model_1, ~ timepoint*group), interaction = 'pairwise') # Significance of overall interaction effect.
margins(model_1, variables = "timepoint", at = list(group = unique(clinical_long$group)))
emmeans(model_1, ~ timepoint*group) # Show marginal means for each level of interaction between timepoint and group

# Calculate marginal means for plotting
emm_1 <- ggpredict(model_1, terms = c("timepoint", "group"))  

# Plot and save graph
plot1 = ggplot(emm_1, aes(x = x, y = predicted, colour = group, group = group)) +  geom_point(size = 3) + geom_line(linewidth = 1) + geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.1) + theme_bw() +
  labs(title = "Predictive Margins of Timepoint × Group with 95% CIs", x = "Timepoint when symptom score was measured (pre/post stimulation)", y = "MADRS symptom scores" )
plot1 # View plot
ggsave(file.path(root,"outputfiles", "NIBS-DAS_clinical_question1_figure_R_2025-12-11.tif"), plot1, width = 6, height = 4, dpi = 300) # Save plot


# ********************************************************************************
# EXAMPLE B – ANALYSIS OF SYMPTOM SCORES FROM MULTIPLE STUDIES
# ********************************************************************************
# You can perform analyses of data combined from multiple studies using an appended dataset.

# Open data
combined_data <- read_csv(file.path(root,"usedata","NIBS-DAS_clinical_exampledata_combined_2025-12-11.csv")) # Open combined data set.

# Reorder your categorical variables as a factor (for interpretation / plotting)
combined_data$timepoint <- factor(combined_data$timepoint, levels = c("ses-pre", "ses-post1"))
combined_data$sex <- factor(combined_data$sex, levels = c("Female", "Male"))
combined_data$group <- factor(combined_data$group, levels = c("Sham", "Real"))

# Clinical Question 2:
# Is there a significant difference in pre vs post symptom scores between active and sham NIBS
# across studies, adjusting for age and sex?

# Treat study_id_number as fixed effect (use when analysing few studies; e.g., 2)
model2fixed <- lmer(symptom_score_madrs ~ age + sex + study_id_number+ timepoint + group + timepoint*group + (1|participant_id), 
                    data = combined_data, 
                    REML = FALSE)
summary(model2fixed)


# Treat study_id_number as random effect (use when analysing many studies; e.g., >10)
model2random <- lmer(symptom_score_madrs ~ sex + age + timepoint + group + timepoint*group + (1 | study_id_number) + (1 | participant_id), 
                       data = combined_data,
                       REML = FALSE)
summary(model2random)
  
# Note: Because this example data contains aggregate data from only 2 studies, the below analyses performed with 'study_id_number' included as a fixed rather than random factor.
  
# Compute Estimated Marginal Means (EMMs)
emm_2 <- emmeans(model2fixed, ~ timepoint * group)
summary(contrast(emm_2, interaction = "pairwise"), infer = TRUE) # Significance of overall interaction effect 
emm # Show EMMs

# Pairwise contrasts
pairs(emm_2)

# Convert to data frame for plotting
emm_2_df <- as.data.frame(emm_2)  

# Graph and save plot
plot2 <- ggplot(emm_2_df, aes(x = timepoint, y = emmean, colour = group, group = group)) + geom_point(size = 3) + geom_line(linewidth = 1) + geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) + theme_bw() + scale_x_discrete(labels = c("Pre", "Post1")) + 
  labs(title = "Estimated Marginal Means Across Studies (n=2)", x = "Timepoint", y = "MADRS symptom score", colour = "Group")
plot2 
ggsave(file.path(root,"outputfiles", "NIBS-DAS_clinical_question2_figure_R_2025-12-11.tif"), plot2, width = 6, height = 4, dpi = 300)


################################################################################

sink(NULL) # Close log 

################################################################################
# END OF SCRIPT
################################################################################
