###############################################################################
# R Script Title: NIBS-DAS_clinical_dm_R_2025-12-11.R
#
# Demonstrates tidyverse-style data management (dm) of a fictional clinical NIBS dataset:
# "NIBS-DAS_clinical_exampledata_2025-12-11_copy.xlsx" / "NIBS-DAS_clinical_exampledata_2025-12-11_copy.tsv"
#
# Code demonstrates:
# (i) importing data from Excel (.xlsx) and Tab Separated Values (.tsv) files
# (ii) variable cleaning and labelling 
# (iii) data checking
# (iv) data layout manipulation ('reshape' long <-> wide)
# (v) combining (append) multiple datasets together

###############################################################################

# ********************************************************************************
#   * LOAD LIBRARIES *
# ********************************************************************************

library(tidyverse)     
library(readxl)        
library(janitor)       
library(labelled)      
library(psych)         
library(summarytools)  

# ********************************************************************************
#   * SET ROOT DIRECTORY *
# ********************************************************************************

# Set root directory
#root <- "[YourFilePath]/NIBS-DAS_clinical_example/collated_participant_data" # Define root directory
root <- "C:/Users/barham/OneDrive - Deakin University/Desktop/Research/Big NIBS Data/Projects/2025_NIBS-DAS/NIBS-DAS_examples/2025-12-11/NIBS-DAS_clinical_example/collated_participant_data"
setwd(root) # Set directory

# Create 'outputfiles' folder (if needed)
dir.create(file.path(root, "outputfiles"), showWarnings = FALSE) 

# Start log
log_file <- file.path(root, "outputfiles", "NIBS-DAS_clinical_dm_log_R_2025-12-11.txt")
  sink(log_file, split = TRUE)
on.exit(sink(NULL)) # Ensure log closes even if errors occur

# ********************************************************************************
#   * OPEN DATA *
# ********************************************************************************

# Option 1: Load data from Excel 
clinical <- read_excel(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_2025-12-11_copy.xlsx"))  |> clean_names()

# Option 2: Load data from TSV (if preferred)
clinical2 <- read_tsv(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_2025-12-11_copy.tsv")) |> clean_names()


# ********************************************************************************
#   * ASSIGN VALUES, ADD LABELS TO VARIABLES, AND CHECK DATA *
# ********************************************************************************

# Sort data by participant_id, group
clinical <- clinical |>
   arrange(participant_id, group)
   
# Clean participant_id (remove 'sub-' prefix and convert to numeric)
clinical <- clinical |>
  mutate(participant_id = str_remove(participant_id, "sub-"),
         participant_id = as.numeric(participant_id))
freq(clinical$participant_id) # Check participant IDs.

# Turn select variables to factors
# Sex
clinical$sex <- factor(clinical$sex,
                       levels = c('Female', 'Male'))
freq(clinical$sex) # Frequency of Sex variable

# Handedness
clinical$handedness <- factor(clinical$handedness,
                              levels = c('Left', 'Right'))
freq(clinical$handedness)

# Group
clinical$group <- factor(clinical$group,
                             levels = c('Sham', 'Real'))
freq(clinical$group)

# Timepoint 
clinical$timepoint <- factor(clinical$timepoint,
                              levels = c('ses-pre', 'ses-post1'))
freq(clinical$timepoint)


# Check participant Age.
freq(clinical$age)
describe(clinical$age)
summary(clinical$age)

# Check participant Years Since Diagnosis.
freq(clinical$years_since_dx)
describe(clinical$years_since_dx)
summary(clinical$years_since_dx)

# Check baseline (ses-pre) clinical symptom scores.
freq(clinical$symptom_score_madrs[clinical$timepoint == "ses-pre"])    # Check frequency of 'Pre' timepoint symptom scores
describe(clinical$symptom_score_madrs[clinical$timepoint == "ses-pre"])
summary(clinical$symptom_score_madrs[clinical$timepoint == "ses-pre"])  # Check summary data of 'Pre' timepoint symptom scores

# Check outcome (ses-post1) clinical symptom scores.
freq(clinical$symptom_score_madrs[clinical$timepoint == "ses-post1"])
describe(clinical$symptom_score_madrs[clinical$timepoint == "ses-post1"])
summary(clinical$symptom_score_madrs[clinical$timepoint == "ses-post1"])

# Count observations (rows) in dataset.
nrow(clinical)

# Save dataset.
clinical_wide %>%
  write_csv(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_long_2025-12-11.csv")) # Save data (as .csv file)


# ********************************************************************************
# * RESHAPE WIDE EXAMPLE
# ********************************************************************************
# Some analyses require your dataset to be in "wide" format to be performed.
# You can reshape your data "wide" using the below code.

# Reshape from long to wide 
clinical_wide <- clinical %>%
  pivot_wider(id_cols = c(participant_id, diagnosis, age, sex, handedness, years_of_education, years_since_dx, 
                          manufacturer_model_name,nibs_protocol, pulse_repetition_frequency, tms_intensity_mso, 
                          tms_pos_centre, group),   # List the variables to retain following reshape
    names_from  = timepoint,                        # List the variable defining the new columns
    values_from = c(tms_rmt, symptom_score_madrs),  # List the variables to widen 
    names_glue  = "{.value}_{timepoint}"            # Rename new columns using this pattern
  )

# Rename variables
clinical_wide <- clinical_wide %>%
  rename(
    RMT_Pre           = `tms_rmt_ses-pre`,
    RMT_Post1         = `tms_rmt_ses-post1`,
    SymptomScore_Pre  = `symptom_score_madrs_ses-pre`,
    SymptomScore_Post1 = `symptom_score_madrs_ses-post1`
  )

# Reorder columns
clinical_wide <- clinical_wide %>%
  relocate(
    participant_id, RMT_Pre, RMT_Post1, SymptomScore_Pre, SymptomScore_Post1,
    diagnosis, age, sex, handedness, years_of_education, years_since_dx,
    manufacturer_model_name, nibs_protocol, pulse_repetition_frequency,
    tms_intensity_mso, tms_pos_centre, group
  )

# Save reshaped dataset.
clinical_wide %>%
  write_csv(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_wide_2025-12-11.csv")) # Save as .csv

# ********************************************************************************
# * RESHAPE LONG EXAMPLE 
# ********************************************************************************
# You can reshape your data back to the original (long) layout using the below code.

# Pivot 'SymptomScore' variable
symptom_long <- clinical_wide %>%
  select(participant_id,	diagnosis, age, sex, handedness, years_of_education, years_since_dx, 
         manufacturer_model_name,	nibs_protocol, pulse_repetition_frequency,	tms_intensity_mso,	
         tms_pos_centre,	group, SymptomScore_Pre, SymptomScore_Post1
         ) %>%
  pivot_longer(cols = starts_with("SymptomScore"), 
               names_to = "timepoint",
               values_to = "symptom_score_madrs") %>%
  mutate(timepoint = gsub("SymptomScore_", "", timepoint))

# Pivot RMT variable
rmt_long <- clinical_wide %>%
  select(participant_id, RMT_Pre, RMT_Post1) %>%
  pivot_longer(cols = starts_with("RMT"),
               names_to = "timepoint",
               values_to = "tms_rmt") %>%
  mutate(timepoint = gsub("RMT_", "", timepoint))

# Combine into one dataset
clinical_long <- symptom_long %>%
  left_join(rmt_long, by = c("participant_id", "timepoint"))

# Rename timepoint values
# clinical_long <- clinical_long %>%
#   mutate(timepoint = recode(timepoint,
#                             "ses-pre" = "Pre",
#                             "ses-post1" = "Post1"))

# Save cleaned and checked dataset (long format).
clinical_long %>%
write_csv(file.path(root, "usedata","NIBS-DAS_clinical_exampledata_long_2025-12-11.csv")) # Save as .csv


# ********************************************************************************
# * APPENDING MULTIPLE DATA SETS * 
# ********************************************************************************
# Multiple data sets can be combined as shown in the below additional example code

# Note: If different studies use the same participant id numbers, these should be updated before appending.

# Prepare first data set for append
dataset_1 <- read_excel(file.path(root, "usedata", "NIBS-DAS_clinical_exampledata_2025-12-11_copy.xlsx"))  |> clean_names() # Load first dataset

dataset_1 <- dataset_1 %>%
  mutate(
    study_id_number = 1,
    participant_id = paste0("st01_", participant_id)
  )

# *Prepare second dataset for append
dataset_2 <- read_excel(file.path(root, "usedata", "NIBS-DAS_clinical_appenddata_2025-12-11_copy.xlsx"))  |> clean_names() # Load second dataset

dataset_2 <- dataset_2 %>%
  mutate(
    study_id_number = 2,
    participant_id = paste0("st02_", participant_id)
  )

# Append data sets
combined_data <- bind_rows(dataset_1, dataset_2) # Append second data file to first

# Check summary statistics to confirm data files have appended correctly
unique(combined_data$participant_id) # Checks IDs are unique (i.e. only one ID per row)
nrow(combined_data)                  # Count observations (rows) in data set.
freq(combined_data$participant_id)   # Check no non-unique participant IDs in combined data sets 
describe(combined_data)              # Describe variables in combined data set

# Save combined dataset (as .csv)
combined_data %>%
  write_csv(file.path(root, "usedata","NIBS-DAS_clinical_exampledata_combined_2025-12-11.csv"))


################################################################################

sink(NULL) # Close log 

################################################################################
# END OF SCRIPT
################################################################################