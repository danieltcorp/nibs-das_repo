################################################################################
# R Script Title: nibs-das_mep_dm_r_2026-02-04.R
#
# R code demonstrating tidyverse-style principles of data management (dm) of a fictional neurophysiological (e.g., TMS MEP) NIBS dataset:
# "nibs-das_mep_exampledata_2026-02-04_copy.xlsx"
#
# Code demonstrates: 
# (i) importing data from Excel (.xlsx) file
# (ii) variable labelling and naming
# (iii) data checking
# (iv) collapsing multiple rows to compute average / mean block MEP values
# (v) dataset layout manipulating ('reshape' long)

################################################################################

################################################################################
# LOAD LIBRARIES 
################################################################################

library(tidyverse)     
library(readxl)        
library(janitor)       
library(labelled)      
library(psych)         
library(summarytools)


################################################################################
# SET DIRECTORY AND OPEN DATA 
################################################################################

# Set your working directory
dir <- "[YourFilePath]/nibs-das_examples/mep_example/collated_participant_data"
setwd(dir)

# Open dataset using collated Excel file containing your data. Can also import a collated .tsv file if preferred.
mep <- read_excel("usedata/nibs-das_mep_exampledata_2026-02-04_copy.xlsx") |> clean_names()


################################################################################
# ASSIGN VALUES, ADD LABELS, AND CHECK DATA
################################################################################

# Sort dataset in ascending order by these variables.
mep <- mep %>%
  arrange(participant_id, protocol_name, trial_number)

# Turn select variables to factors.
# 'Sex'.
mep$sex <- factor(mep$sex,
                  levels = c('Female', 'Male'))
freq(mep$sex) # Frequency table of cleaned 'Sex' variable

# 'Handedness'.
mep$handedness <- factor(mep$handedness,
                         levels = c('Left', 'Right'))
freq(mep$handedness)

# 'tms_stim_mode'.
mep$tms_stim_mode <- factor(mep$tms_stim_mode,
                         levels = c('single', 'dual'))
freq(mep$tms_stim_mode)

# Check participant IDs.
freq(mep$participant_id)

# Check participant Age.
freq(mep$age) # Frequency table of raw 'age' variable
describe(mep$age) # Descriptive statistics of raw 'age' variable
summary(mep$age) # Summary data of raw 'age' variable

# Check TMS trial number.
freq(mep$trial_number)

# Check participant resting motor threshold (RMT).
describe(mep$rmt_intensity)
summary(mep$rmt_intensity)

# Check baseline (pre-TMS) FDI EMG amplitude.
freq(mep$pre_rms_fdi)
describe(mep$pre_rms_fdi)
summary(mep$pre_rms_fdi)

# Check FDI muscle MEP amplitude by trial type.
describeBy(mep$mep_ampl_fdi, mep$tms_stim_mode,
           mat = TRUE, digits = 3)

# Check baseline (pre-TMS) APB EMG amplitude.
freq(mep$pre_rms_apb)
describe(mep$pre_rms_apb)
summary(mep$pre_rms_apb)

# Check APB muscle MEP amplitude by trial type. 
describeBy(mep$mep_ampl_apb, mep$tms_stim_mode,
           mat = TRUE, digits = 3)

# Count observations (rows) in data set.
nrow(mep)

# Save cleaned uncollapsed dataset - a version with MEP amplitudes for each trial rather than collapsed by MEP block (as per below). 
# Investigators may also wish to incorporate all MEPs in their analyses without collapsing by MEP block (e.g., by nesting MEPs within blocks of trials).
mep_uncollapsed <- mep
mep_uncollapsed %>%
  write_csv("usedata/nibs-das_mep_exampledata_uncollapsed.csv")


################################################################################
# COLLAPSE DATA 
################################################################################

# Use collapse command to compute the mean of MEP amplitudes in FDI and APB muscles by participants and TMS 
# stimulation modes (dual or single pulses). These (and similar) operations should be done within software 
# rather than by editing data in spreadsheets, to ensure all data are retained, and for version/operation control.

# The variables after 'group_by' are those you want the data collapsed within, 'summarise' computes the mean score for variables 
# which vary by trial (e.g., MEP amplitudes), and the variables specified as "var = 'first'(var)" retain the value of the first row of 
# that variable in the collapsed data (this only works for variables that do not vary within 'partipant_id' and 'tms_stim_mode').

mep_meandata <- mep %>%
  group_by(participant_id, sex, handedness, tms_stim_mode) %>%  # Collapse across these variables
  summarise(mep_ampl_fdi = mean(mep_ampl_fdi, na.rm = TRUE), pre_rms_fdi = mean(pre_rms_fdi, na.rm = TRUE), mep_ampl_apb = mean(mep_ampl_apb, na.rm = TRUE), pre_rms_apb = mean(pre_rms_apb, na.rm = TRUE),   # Compute the mean score of these variables per participant
  age = first(age), manufacturer_model_name = first(manufacturer_model_name), protocol_name = first(protocol_name), waveform = first(waveform), current_direction = first(current_direction), targeting_method = first(targeting_method ), pulse_intensity_rmt = first(pulse_intensity_rmt), second_pulse_intensity_rmt = first(second_pulse_intensity_rmt), inter_stimulus_interval = first(inter_stimulus_interval), rmt_intensity = first(rmt_intensity),  tms_pos_centre = first(tms_pos_centre), # Retain the value in the first row for these variables                            
  )

# Reorder the variables.
 mep_meandata <- mep_meandata %>%
  relocate(participant_id, sex, handedness,	tms_stim_mode,	age,	pulse_intensity_rmt,	second_pulse_intensity_rmt,	inter_stimulus_interval,	rmt_intensity,	mep_ampl_fdi,	pre_rms_fdi,	mep_ampl_apb,	pre_rms_apb,	manufacturer_model_name,	protocol_name,	waveform,	current_direction,	targeting_method,	tms_pos_centre)

# Save dataset
mep_meandata %>%
  write_csv("usedata/nibs-das_mep_exampledata_blockmean.csv")


################################################################################
# RESHAPE EXAMPLE - LONG
################################################################################

# Some analyses require data manipulation and reshaping. For example, in our original data, the MEPs for the FDI and 
# APB muscles were in separate columns. However, to analyse MEP values between these muscles, this variables would need 
# to be reshaped "long", into the one column, to produce a new 'Muscle' variable. Note that the above dataset was technically 
# already "long" given that single and dual pulse MEPs were represented across two rows per participant (tms_stim_mode 
# variable), so this reshape will make the dataset longer again.

# Print means for these variables to check they match those after reshape
describe (mep_meandata$mep_ampl_fdi)
describe (mep_meandata$mep_ampl_apb)
describe (mep_meandata$pre_rms_fdi)
describe (mep_meandata$pre_rms_fdi)

# Reshape data long
mep_meandata_long <- mep_meandata %>%
  pivot_longer(
    cols = c(mep_ampl_fdi, mep_ampl_apb, pre_rms_fdi, pre_rms_apb), # Variables to reshape 
    names_to = c(".value", "muscle"), # Name new variable (e.g., 'muscle') which will group the reshaped variables 
    names_pattern = "(mep_ampl|pre_rms)_(fdi|apb)" # Specify the pattern to name new variables from existing variable names (e.g., drop '_fdi' and '_apb' from 'mep_ampl'|'pre_rms')
  ) %>%
  mutate(
    muscle = factor(muscle, levels = c("fdi", "apb"), labels = c("FDI", "APB")) # Label the values within 'muscle' as "FDI" and "APB", respectively
  )

# Note: the above reshapes what were previously two columns with the names 'mep_ampl_fdi' and 'mep_ampl_apb' 
# into a single variable named 'mep_ampl' (and does the same for 'pre_rms'), which will be the DV in the example analyses, 
# and creates a new variable named 'muscle', to be used as an IV in the analyses.
  
# Check frequency of new 'Muscle' variable
freq(mep_meandata_long$muscle)

# Check mean values are same as above before reshape
mep_meandata_long %>%
  group_by(muscle) %>%
  summarise(
    Nmep = sum(!is.na(mep_ampl)), Mean_mep  = mean(mep_ampl, na.rm = TRUE), SD_mep = sd(mep_ampl, na.rm = TRUE), Min_mep = min(mep_ampl, na.rm = TRUE), Max_mep   = max(mep_ampl, na.rm = TRUE),
    N_pre = sum(!is.na(pre_rms)), Mean_pre  = mean(pre_rms, na.rm = TRUE), SD_pre = sd(pre_rms, na.rm = TRUE), Min_pre   = min(pre_rms, na.rm = TRUE),  Max_pre   = max(pre_rms, na.rm = TRUE))

# Sort dataset in ascending order by these variables.
mep_meandata_long <- mep_meandata_long %>%
  arrange(participant_id, tms_stim_mode, muscle)

# Reorder the variables.
mep_meandata_long <- mep_meandata_long %>%
  relocate (participant_id, sex, age, handedness, rmt_intensity, protocol_name, muscle, tms_stim_mode,
        mep_ampl, pre_rms, pulse_intensity_rmt, second_pulse_intensity_rmt, inter_stimulus_interval,
        manufacturer_model_name, waveform, current_direction, targeting_method, tms_pos_centre) 

# Save cleaned and checked dataset
mep_meandata_long %>%
  write_csv("usedata/nibs-das_mep_exampledata_blockmean_long.csv")

################################################################################
# END OF SCRIPT
################################################################################