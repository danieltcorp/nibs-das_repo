################################################################################
# R Script Title: NIBS-DAS_mep_dm_R_2025-12-11.R
#
# Demonstrates tidyverse-style data management (dm) of a fictional neurophysiological NIBS dataset:
# "NIBS-DAS_mep_exampledata_2025-12-11_copy.xlsx" / "NIBS-DAS_mep_exampledata_2025-12-11_copy.tsv"
#
# Code demonstrates: 
# (i) importing data from Excel (.xlsx) and Tab Separated Value (.tsv) files
# (ii) variable labelling and naming
# (iii) data checking
# (iv) collapsing multiple rows to compute average / mean MEP values
# (v) dataset layout manipulating ('reshape' long <-> wide)
# (vi) generating new variables from existing data

################################################################################

# ********************************************************************************
#   * LOAD LIBRARIES *
# ********************************************************************************

library(tidyverse)     
library(readxl)        
library(janitor)       
library(labelled)      
library(psych)         
library(summarytools)

################################################################################
# SET ROOT DIRECTORY
################################################################################

# Set root directory
#root <- "[YourFilePath]/NIBS-DAS_mep_example/collated_participant_data"
root <- "C:/Users/barham/OneDrive - Deakin University/Desktop/Research/Big NIBS Data/Projects/2025_NIBS-DAS/NIBS-DAS_examples/2025-12-11/NIBS-DAS_mep_example/collated_participant_data"
setwd(root) # Set directory

# Create 'outputfiles' folder (if needed)
dir.create(file.path(root, "outputfiles"), showWarnings = FALSE) 

# Start log
log_file <- file.path(root, "outputfiles", "NIBS-DAS_mep_dm_log_R_2025-12-11.txt")
  sink(log_file, split = TRUE)
on.exit(sink(NULL)) # Ensure log closes even if errors occur

################################################################################
# OPEN DATA
################################################################################

# Option 1: Load data from Excel 
mep <- read_excel(file.path(root, "usedata", "NIBS-DAS_mep_exampledata_2025-12-11_copy.xlsx")) |> clean_names()

# Option 2: Load data from TSV (if preferred)
mep2 <- read_tsv(file.path(root, "usedata", "NIBS-DAS_mep_exampledata_2025-12-11_copy.tsv")) |> clean_names()


################################################################################
# ASSIGN VALUES, ADD LABELS, AND CHECK DATA
################################################################################

# Sort dataset by participant number, nibs protocol, and trial number
mep <- mep %>%
  arrange(participant_id, nibs_protocol, trial_number)

# Turn select variables to factors
# Sex
mep$sex <- factor(mep$sex,
                  levels = c('Female', 'Male'))
freq(mep$sex) # Frequency of Sex variable

# Handedness
mep$handedness <- factor(mep$handedness,
                         levels = c('Left', 'Right'))
freq(mep$handedness)

# Trial type
mep$trial_type <- factor(mep$trial_type,
                         levels = c('Unconditioned', 'Conditioned'))
freq(mep$trial_type)

# Check participant IDs.
freq(mep$participant_id)

# Check participant Age.
freq(mep$age)
describe(mep$age)
summary(mep$age)

# Check TMS trial number.
freq(mep$trial_number)

# Check participant resting motor threshold (RMT).
describe(mep$tms_rmt)
summary(mep$tms_rmt)

# Check baseline (pre-TMS) FDI EMG amplitude.
freq(mep$fdi_pre_rms)
describe(mep$fdi_pre_rms)
summary(mep$fdi_pre_rms)

# Check FDI muscle MEP amplitude by trial type.
describeBy(mep$fdi_mep_ampl, mep$trial_type,
           mat = TRUE, digits = 3)

# Check baseline (pre-TMS) APB EMG amplitude.
freq(mep$apb_pre_rms)
describe(mep$apb_pre_rms)
summary(mep$apb_pre_rms)

# Check APB muscle MEP amplitude by trial type. 
describeBy(mep$apb_mep_ampl, mep$trial_type,
           mat = TRUE, digits = 3)

# Count observations (rows) in data set.
nrow(mep)

# Save clean and checked dataset, in an uncollapsed layout
mep_uncollapsed <- mep
mep_uncollapsed %>%
  write_csv(file.path(root, "usedata","NIBS-DAS_mep_exampledata_uncollapsed_wide_2025-12-11.csv"))

# An uncollapsed dataset records separate MEP amplitudes for each trial (i.e., # each TMS pulse) as an individual observation. 
# This preserved within-subject variability in MEPs, and increases statistical power when performing mixed-models.


################################################################################
# COLLAPSE DATA 
################################################################################

# Some researchers may like to perform analyses on MEP amplitudes averaged over blocks of trials. 
# Statistical software can easily compute mean block MEP amplitudes, as demonstrated below.

# The below code computes the mean and standard deviation (SD) of MEP amplitudes in
# FDI and APB muscles for 'conditioned' and 'unconditioned' pulses.
mep_meandata <- mep %>%
  group_by(participant_id, trial_type) %>%  # Collapse across these variables
  summarise(
    mean_fdi_mep_ampl = mean(fdi_mep_ampl, na.rm = TRUE), # Compute mean MEP amplitudes in FDI muscles
    sd_fdi_mep_ampl = sd(fdi_mep_ampl, na.rm = TRUE),     # Compute standard deviations of MEP amplitudes in FDI muscle
    mean_apb_mep_ampl = mean(apb_mep_ampl, na.rm = TRUE),
    sd_apb_mep_ampl = sd(apb_mep_ampl, na.rm = TRUE),
    age = first(age),                                     # Retain following variables in collapsed data layout. Use data    
    sex = first(sex),                                     # from first row per participant in new layout.
    tms_rmt = first(tms_rmt),                             #  
    fdi_pre_rms = first(fdi_pre_rms),                     # Note: Will only work for variables where data does not vary 
    apb_pre_rms = first(apb_pre_rms)                      # within 'Participant_id' and 'trial_type' variables. 
  )

# Reorder the variables.
mep_meandata <- mep_meandata %>%
  select(participant_id, trial_type, 
         fdi_pre_rms, mean_fdi_mep_ampl, sd_fdi_mep_ampl, 
         apb_pre_rms, mean_apb_mep_ampl, sd_apb_mep_ampl, 
         age, sex, tms_rmt
         )

# Save collapsed ('mean block') data set layout.
mep_meandata %>%
  write_csv(file.path(root, "usedata","NIBS-DAS_mep_exampledata_meanblock_wide_2025-12-11.csv"))

# Use this data set to analyse MEP amplitude values averaged across blocks of trials.


################################################################################
# RESHAPE EXAMPLE - LONG
################################################################################

# Some analyses (for example, to analyse MEP values by different muscles), would
# need the data formatted in "long-long" format. This manipulation will produce a 
# new 'Muscle' variable.

# Rename variables for reshape. 
mep_mean_long <- mep_meandata %>%
  dplyr::rename(mean_MEPampl0 = mean_fdi_mep_ampl,
                mean_MEPampl1 = mean_apb_mep_ampl
               )

# Reshape 'mean_MEPampl' data long
mep_mean_long <- mep_mean_long %>%
  pivot_longer(cols = starts_with('mean_MEPampl'),
               names_to = 'muscle',
               values_to = 'MEPampl') %>%
  mutate(muscle = gsub('MEPampl', "",muscle))

# Note: the above reshapes what were previously two columns with the names 
# 'mean_fdi_mep_ample' and 'mean_apb_mep_ample' into a single variable named 
# 'MEPampl' which can be used as a DV, and creates a new variable named 
# 'Muscle' which can be be used as an IV in analyses.

# Label 'Muscle' variable
mep_mean_long$muscle <- factor(mep_mean_long$muscle,
                                   levels = c('mean_0', 'mean_1'),
                                   labels = c('FDI', 'APB'))

#Reorder the variables
mep_mean_long <- mep_mean_long %>%
  select(participant_id, trial_type, muscle, MEPampl, 
         fdi_pre_rms, sd_fdi_mep_ampl, apb_pre_rms, sd_apb_mep_ampl, 
         age, sex, tms_rmt)

# Check number of observations for each 'Muscle'
freq(mep_mean_long$muscle)

# Save 'long' data set layout.
mep_mean_long %>%
  write_csv(file.path(root, "usedata","NIBS-DAS_mep_exampledata_meanblock_long_2025-12-11.csv"))

# We can use this dataset to include 'Muscle' as an IV in our analyses.


################################################################################
# RESHAPE WIDE EXAMPLE
################################################################################
# You can reshape your data back to the layout it was originally in (via a 'wide' reshape)
# using the below code.

# Reshape data wide.
mep_mean_wide <- mep_mean_long %>% # Note: This removes the 'Muscle' variable and reshapes 'MEPampl' variable
  pivot_wider(names_from = 'muscle',         # into separate columns named 'MEPampl0' and 'MEPampl1'  
              values_from = 'MEPampl') %>% 
  dplyr::rename(                             # Rename variables with unique labels after reshaping.                 
              mean_fdi_mep_ampl = 'FDI',
              mean_apb_mep_ampl = 'APB') 

# Reorder the variables.
mep_mean_wide <- mep_mean_wide %>%
  select(participant_id, trial_type, 
         fdi_pre_rms, mean_fdi_mep_ampl, sd_fdi_mep_ampl, 
         apb_pre_rms, mean_apb_mep_ampl, sd_apb_mep_ampl, 
         age, sex, tms_rmt)


# Use this dataset to include 'fdi_mep_ampl' and 'apb_mep_ampl' as DVs.


################################################################################
# (OPTIONAL) CREATE NEW VARIABLE: MEP BLOCK
################################################################################

# The following code demonstrates the generation of a new variable called 'mep-lock'.  
# This variable can be use as a 'random' variable in multilevel analyses measuring
# nesting of MEPs within blocks of TMS trials

# Generate empty variable called 'mep-block'
# Add data to 'mep-block' based on data in another variable (e.g., 'trial number')

mep_block <- mep_uncollapsed %>%
  mutate(
    mep_block = case_when(
      trial_number >= 1 & trial_number <= 20 ~ "Pre",   # Add string 'Pre' to rows where 'trial_number' ranges between 1 and 20.
      trial_number >= 21 & trial_number <= 40 ~ "Post", # Add string 'Post' to rows where 'trial_number' ranges between 21 and 40.
      TRUE ~ NA_character_
    )
  )

# Sort data by these variables
mep_block <- mep_block %>%
  arrange(participant_id, trial_number, mep_block)

# Save 'MEP block' data set.
mep_block %>%
  write_csv(file.path(root, "usedata","NIBS-DAS_mep_exampledata_mep-block_2025-12-11.csv"))

# Use this data set to include 'mep_block' as an IV in analyses. For example, this 
# variable could be used as a random variable in multilevel analyses measuring nesting 
# of MEPs within blocks of trials (e.g., the first and last 20 trials in a session).


################################################################################

sink(NULL) # Close log 

################################################################################
# END OF SCRIPT
################################################################################
