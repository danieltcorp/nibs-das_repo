/*******************************************************************************
Do-file title: nibs-das_mep_dm_stata_2026-02-04.do    		 

Stata code file demonstrating principles of data management (dm) of a fictional neurophysiological (e.g., TMS MEP) dataset: 
"nibs-das_mep_exampledata_2026-02-04_copy.xlsx"

Code demonstrates: 
(i) importing data from Excel (.xlsx) file
(ii) variable labelling and naming
(iii) data checking
(iv) collapsing multiple rows to compute average / mean block MEP values
(v) dataset layout manipulating ('reshape' long)
	 
*******************************************************************************/

clear all 
capture log close
set more off
version 17.0


********************************************************************************
* SET DIRECTORY AND OPEN DATA *
********************************************************************************

*Set your working directory
cd "[YourFilePath]/nibs-das_examples/mep_example/collated_participant_data"

* Open dataset using collated Excel file containing your data. Can also import a collated .tsv file if preferred.
import excel using "usedata/nibs-das_mep_exampledata_2026-02-04_copy.xlsx", first


********************************************************************************
* ASSIGN VALUES, ADD LABELS TO VARIABLES, AND CHECK DATA *
********************************************************************************

* Sort dataset in ascending order by these variables.
sort participant_id protocol_name trial_number 

* Destring and label 'sex' variable.
tab sex, missing // Frequency table of 'sex' variable
	replace sex = "0" if sex == "Female" // Replaces 'Female' with string '0'
	replace sex = "1" if sex == "Male" // Replaces 'Male' with string '1'
	destring sex, replace // Convert string to numeric
	lab def sexl 0 "Female" 1 "Male" // Label values 0 and 1 as 'Female' and 'Male', respectively
	lab val sex sexl // Add value label to destringed variable
tab sex, missing // Frequency table of cleaned 'Sex' variable

* Destring and label 'handedness' variable.
tab handedness, missing
	replace handedness = "0" if handedness == "Left" 
	replace handedness = "1" if handedness == "Right"
	destring handedness, replace
	lab def handednessl 0 "Left" 1 "Right"
	lab val handedness handednessl
tab handedness, missing

* Destring and label 'tms_stim_mode' variable.
tab tms_stim_mode, missing
	replace tms_stim_mode = "0" if tms_stim_mode == "single"
	replace tms_stim_mode = "1" if tms_stim_mode == "dual"
	destring tms_stim_mode, replace
	lab def tms_stim_model 0 "single" 1 "dual"
	lab val tms_stim_mode tms_stim_model
	lab var tms_stim_mode "Type of MEP"	
tab tms_stim_mode, missing

* Check participant IDs.
tab	participant_id, missing 

* Check participant age.
tab age, missing
sum age, detail

* Check TMS trial number.
tab trial_number, missing

* Check participant resting motor threshold (RMT).
sum rmt_intensity, detail

* Check baseline (pre-TMS) FDI EMG amplitude.
tab pre_rms_fdi, missing
sum pre_rms_fdi, detail

* Check FDI muscle MEP amplitude by trial type.
sum mep_ampl_fdi if tms_stim_mode == 0, detail 
sum mep_ampl_fdi if tms_stim_mode == 1, detail 

* Check baseline (pre-TMS) APB EMG amplitude.
tab pre_rms_apb, missing
sum pre_rms_apb, detail

* Check APB muscle MEP amplitude by trial type. 
sum mep_ampl_apb if tms_stim_mode == 0, detail 
sum mep_ampl_apb if tms_stim_mode == 1, detail 

* Count observations (rows) in dataset.
count

/* Save cleaned uncollapsed dataset - a version with MEP amplitudes for each trial rather than collapsed by 
MEP block (as per below). Investigators may also wish to incorporate all MEPs in their analyses without 
collapsing by MEP block (e.g., by nesting MEPs within blocks of trials). */
save "usedata/nibs-das_mep_exampledata_uncollapsed.dta", replace 


********************************************************************************
* COLLAPSE DATA *
********************************************************************************
/* Use collapse command to compute the mean of MEP amplitudes in FDI and APB muscles by participants and TMS 
stimulation modes (dual or single pulses). These (and similar) operations should be done within software 
rather than by editing data in spreadsheets, to ensure all data are retained, and for version/operation control.

The variables after 'mean' are those you want averaged or retained in the dataset, the variables after 'first' are
categorical IVs you want to retain, and the variables after 'by' are those you want the data collapsed within. */

collapse (mean) age pulse_intensity_rmt second_pulse_intensity_rmt inter_stimulus_interval ///
	rmt_intensity mep_ampl_fdi pre_rms_fdi mep_ampl_apb pre_rms_apb ///
(first) ManufacturerModelName protocol_name waveform ///
	current_direction targeting_method tms_pos_centre, ///
by(participant_id sex handedness tms_stim_mode )

* Save dataset
save "usedata/nibs-das_mep_exampledata_blockmean.dta", replace // Save mean MEP data in wide layout


********************************************************************************
* RESHAPE EXAMPLE - LONG *
********************************************************************************
/* Some analyses require data manipulation and reshaping. For example, in our original data, the MEPs for the FDI and 
APB muscles were in separate columns. However, to analyse MEP values between these muscles, this variable would need to 
be reshaped "long", into the one column, to produce a new 'Muscle' variable. Note that the above dataset was technically 
already "long" given that single and dual pulse MEPs were represented across two rows per participant (tms_stim_mode 
variable), so this reshape will make the dataset longer again. */

* Print means for these variables to check they match those after reshape
summ mep_ampl_fdi mep_ampl_apb pre_rms_fdi pre_rms_apb

* Rename variables for reshape. 
rename mep_ampl_fdi mep_ampl0 // Relabel 'mep_ampl_fdi' variable to 'mep_ampl0'
rename mep_ampl_apb mep_ampl1 // Relabel 'mep_ampl_apb' variable to 'mep_ampl1'
rename pre_rms_fdi pre_rms0 // Relabel 'pre_rms_fdi' to 'pre_rms0'
rename pre_rms_apb pre_rms1 // Relabel 'pre_rms_apb' to 'pre_rms1'

/* Note: In STATA, variables need to begin with the same 'stub' prior to 
reshaping. The above already had the same stubs (mep_ampl_ and pre_rms_) but this 
functions better with numeric variables after the stub */

* Reshape data 'long'.
reshape long mep_ampl pre_rms, i(participant_id tms_stim_mode) j(muscle)

/* Note: the above reshapes what were previously two columns with the names 'mep_ampl_fdi' and 'mep_ampl_apb' into 
a single variable named 'mep_ampl' (and does the same for 'pre_rms'), which will be the DV in the example analyses, 
and creates a new variable named 'muscle', to be used as an IV in the analyses. */

*Label 'muscle' variable.
tab muscle, missing
	lab def musclel 0 "FDI" 1 "APB" // Label values 0 and 1 as 'FDI' and 'APB', respectively
	lab val muscle musclel
tab muscle, missing // Check frequency of new 'Muscle' variable

*Check mean values are same as above before reshape
by muscle, sort: summ mep_ampl
by muscle, sort: summ pre_rms

*Sort and reorder the variables.
sort participant_id tms_stim_mode muscle 
order participant_id sex age handedness  rmt_intensity protocol_name muscle tms_stim_mode ///
mep_ampl pre_rms pulse_intensity_rmt second_pulse_intensity_rmt inter_stimulus_interval ///
ManufacturerModelName waveform current_direction targeting_method tms_pos_centre

* Save cleaned and checked dataset
save "usedata/nibs-das_mep_exampledata_blockmean_long.dta", replace 

********************************************************************************
* END OF SCRIPT *
********************************************************************************