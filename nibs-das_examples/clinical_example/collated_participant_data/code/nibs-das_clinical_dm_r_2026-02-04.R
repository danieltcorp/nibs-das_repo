###############################################################################
# R Script Title: nibs-das_clinical_dm_r_2026-02-04.R
#
# R code demonstrating tidyverse-style data management (dm) of a fictional clinical NIBS dataset:
# "nibs-das_clinical_exampledata_2026-02-04_copy.xlsx".
#
# Code demonstrates:
# (i) importing data from Excel (.xlsx) file
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
#   * SET DIRECTORY AND OPEN DATA *
# ********************************************************************************

# Set your working directory.
dir <- "[YourFilePath]/nibs-das_examples/clinical_example/collated_participant_data"
setwd(dir)

# Open dataset using collated Excel file containing your data. Can also import a collated .tsv file if preferred.
clinical <- read_excel("usedata/nibs-das_clinical_exampledata_2026-02-04_copy.xlsx") |> clean_names()


# ********************************************************************************
#   * ASSIGN VALUES, ADD LABELS TO VARIABLES, AND CHECK DATA *
# ********************************************************************************

# Sort dataset in ascending order by these variables.
clinical <- clinical |>
   arrange(participant_id, group)
   
# Destring and label 'participant_id' variable.
clinical <- clinical |>
  mutate(participant_id = str_remove(participant_id, "sub-"), # Remove 'sub-' prefix from participant_id
         participant_id = as.numeric(participant_id)) # Convert string to numeric
freq(clinical$participant_id) # Check participant IDs

# Turn select variables to factors
# 'Sex'
clinical$sex <- factor(clinical$sex,
                       levels = c('Female', 'Male'))
freq(clinical$sex) # Frequency of Sex variable

# 'Handedness'
clinical$handedness <- factor(clinical$handedness,
                              levels = c('Left', 'Right'))
freq(clinical$handedness)

# 'Group'
clinical$group <- factor(clinical$group,
                             levels = c('Sham', 'Real'))
freq(clinical$group)

# 'Session ID' 
clinical$session_id <- factor(clinical$session_id,
                              levels = c('ses-pre', 'ses-post1'))
freq(clinical$session_id)


# Check participant Age.
freq(clinical$age) # Frequency table of raw 'age' variable
describe(clinical$age) # Descriptive statistics of raw 'age' variable
summary(clinical$age) # Summary data of raw 'age' variable

# Check participant Years Since Diagnosis.
freq(clinical$years_since_dx)
describe(clinical$years_since_dx)
summary(clinical$years_since_dx)

# Check baseline (ses-pre) clinical symptom scores.
freq(clinical$symptom_score_madrs[clinical$session_id == "ses-pre"])    # Frequency table of pre-stimulation 'session_id' symptom scores
describe(clinical$symptom_score_madrs[clinical$session_id == "ses-pre"]) # Descriptive statistics of pre-stimulation 'session_id' symptom scores
summary(clinical$symptom_score_madrs[clinical$session_id == "ses-pre"])  # Summary data of pre-stimulation 'session_id' symptom scores

# Check outcome (ses-post1) clinical symptom scores.
freq(clinical$symptom_score_madrs[clinical$session_id == "ses-post1"])
describe(clinical$symptom_score_madrs[clinical$session_id == "ses-post1"])
summary(clinical$symptom_score_madrs[clinical$session_id == "ses-post1"])

# Count observations (rows) in dataset.
nrow(clinical)

# Reorder the variables.
clinical <- clinical %>%
  relocate(
    participant_id, diagnosis, age, sex, handedness, years_of_education,  years_since_dx, 
    rmt_intensity, group, session_id, symptom_score_madrs, manufacturer_model_name, 
    protocol_name, tms_pos_centre, pulse_rate, pulse_intensity_rmt
  )

# Save dataset.
clinical_long <- clinical
clinical_long %>%
  write_csv("usedata/nibs-das_clinical_exampledata_long.csv") # Save data (as .csv file)


# ********************************************************************************
# * RESHAPE WIDE EXAMPLE
# ********************************************************************************
# Some analyses require your dataset to be in a "wide" format to be performed.
# You can reshape your data "wide" using the below code.

# Reshape data "wide".
clinical_wide <- clinical_long %>%
  pivot_wider(id_cols = c(participant_id, diagnosis, age, sex, handedness, years_of_education, years_since_dx, 
                          manufacturer_model_name,protocol_name, pulse_rate, pulse_intensity_rmt, 
                          tms_pos_centre, rmt_intensity, group),  # List the variables to retain following reshape
    names_from  = session_id,              # List the variable defining the new columns
    values_from = c(symptom_score_madrs),  # List the variable to widen 
    names_glue  = "{.value}_{session_id}"  # Rename new columns using this pattern
  )

# Note: This removes the 'session_id' variable and reshapes the 'symptom_score_madrs' variable 
# into separate variables for ses-pre and ses-post1 session IDs.

# Rename 'symptom_score_madrs' variable with unique labels after reshaping.
clinical_wide <- clinical_wide %>%
  rename(
    symptom_score_pre  = `symptom_score_madrs_ses-pre`,    # Relabel 'symptom_score_madrs0' to 'symptom_score_pre' 
    symptom_score_post1 = `symptom_score_madrs_ses-post1`  # Relabel 'symptom_score_madrs1' to 'symptom_score_post1' 
  )

# When in "wide" format, new variables can be computed using the data from two or more existing variables within the dataset. 
# For example, a researcher may like to compute the change in MADRS symptom scores before and after NIBS as a 'percentage change' 
# score and use this as the DV in their analyses as per the following: 

# Generate 'Percentage Change' (pct_change) variable. Positive scores indicate improvement.
clinical_wide$pct_change <- ((clinical_wide$symptom_score_pre - clinical_wide$symptom_score_post1) / (clinical_wide$symptom_score_pre)) * 100 

# Reorder the variables.
clinical_wide <- clinical_wide %>%
  relocate(
    participant_id, diagnosis, age, sex, handedness, years_of_education,  years_since_dx, 
    rmt_intensity, group, symptom_score_pre, symptom_score_post1, pct_change, manufacturer_model_name, 
    protocol_name, tms_pos_centre, pulse_rate, pulse_intensity_rmt
  )

# Save reshaped dataset.
clinical_wide %>%
  write_csv("usedata/nibs-das_clinical_exampledata_wide.csv")


# ********************************************************************************
# * RESHAPE LONG EXAMPLE 
# ********************************************************************************
# You can reshape your data back to the original ("long") layout using the below code.

# Pivot 'SymptomScore' variable
clinical_long2 <- clinical_wide %>%
  select(participant_id,	diagnosis, age, sex, handedness, years_of_education, years_since_dx, 
         rmt_intensity, group, symptom_score_pre, symptom_score_post1, pct_change, manufacturer_model_name,	
         protocol_name, tms_pos_centre, pulse_rate,	pulse_intensity_rmt,	
         ) %>%
  pivot_longer(cols = starts_with("symptom_score"), 
               names_to = "session_id",
               values_to = "symptom_score_madrs") %>%
  mutate(session_id = gsub("symptom_score_", "", session_id))

#  Note: the above reshapes what were previously two columns with the names 'symptom_score_pre' 
# and 'symptom_score_post1' into a single variable named 'symptom_score_madrs', which will be 
# a DV, and creates a new variable named 'session_id', to be used as an IV in our upcoming analyses. 

# Remove 'Percentage Change' variable
clinical_long2$pct_change <- NULL

# Reorder the variables.
clinical_long2 <- clinical_long2 %>%
  relocate(
    participant_id, diagnosis, age, sex, handedness, years_of_education,  years_since_dx, 
    rmt_intensity, group, session_id, symptom_score_madrs, manufacturer_model_name, 
    protocol_name, tms_pos_centre, pulse_rate, pulse_intensity_rmt
  )


# ********************************************************************************
# * COMBINING MULTIPLE DATASETS * 
# ********************************************************************************
# Multiple datasets can be combined using the bind_rows (append) function of R, as shown in the below example.

# Note: When combining studies, study and participant numbers need to be unique. Here, we assign a 'study_participant_id'  
# prefix to each participant id number (e.g., st01_ or st02_) to designate which dataset each participant is from. We 
# also generate a new 'study_id' variable  which can be used in analyses to examine differences between studies.
  

# Call and prepare first data set for append
dataset_1 <- read_excel("usedata/nibs-das_clinical_exampledata_2026-02-04_copy.xlsx")  |> clean_names() # Load first dataset

dataset_1 <- dataset_1 %>%
  mutate(
    study_id = 1, # Generate variable numbering this the first dataset
    study_participant_id = paste0("st01_", participant_id) # Generate a new variable called 'study_participant_id' to give a unique id for each individual / entity in the combined dataset.
  )

# Call and prepare second dataset for append
dataset_2 <- read_excel("usedata/nibs-das_clinical_seconddataset_2026-02-04_copy.xlsx") |> clean_names() # Load second dataset
dataset_2 <- dataset_2 %>%
  mutate(
    study_id = 2,
    study_participant_id = paste0("st02_", participant_id)
  )

# Note: This second fictional dataset was created separately to demonstrate how to append multiple data sets together. The layout of this 
# second dataset matches the example dataset layout, and can be viewed within the 'nibs-das_clinical_seconddataset_2026-02-04_copy.xlsx' spreadsheet. 

# Append datasets
combined_data <- bind_rows(dataset_1, dataset_2) # Append second datafile to first

# Check summary statistics to confirm data files have appended correctly
unique(combined_data$study_participant_id) # Checks participant IDs are unique. Use to confirm each individual / entity in appended dataset has a unique ID
nrow(combined_data) # Count observations (rows) in dataset
describe(combined_data) # Describe variables in combined dataset

# Save combined dataset (as .csv)
combined_data %>%
  write_csv("usedata/nibs-das_clinical_exampledata_combined.csv")


################################################################################
# END OF SCRIPT
################################################################################