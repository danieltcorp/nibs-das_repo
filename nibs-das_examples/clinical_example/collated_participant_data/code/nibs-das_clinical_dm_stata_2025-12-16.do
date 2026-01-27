/*******************************************************************************
Do-file title   NIBS-DAS_clinical_dm_stata_2025-12-16.do   		 
 
Stata code file demonstrating principles of data management (dm) of a fictional clinical NIBS dataset: 
"NIBS-DAS_clinical_exampledata_2025-12-11_copy.xlsx" /"NIBS-DAS_clinical_exampledata_2025-12-11_copy.tsv".

Code demonstrates: 
(i) importing data from Excel (.xlsx) file
(ii) variable cleaning and labelling
(iii) data checking
(iv) data layout manipulation ('reshape' long <-> wide)
(v) combining (append) multiple datasets together
 
*******************************************************************************/

clear all 
capture log close
set more off
*version 17.0
version 15.0


********************************************************************************
* SET DIRECTORY AND OPEN DATA *
********************************************************************************

*Set your working directory
*cd "[YourFilePath]/NIBS-DAS_clinical_example/collated_participant_data"
cd "/Users/danielcorp/Dropbox/2016_BigTMSdata/0_Projects/0_2023_NIBS-DAS/NewFolderStructure_Oct25/FolderStructure_2025-12-16_DC/NIBS-DAS_clinical_example/collated_participant_data"

* Open dataset using collated Excel file containing your data. Can also import a collated tsv file if preferred.
import excel using "usedata/NIBS-DAS_clinical_exampledata_2025-12-13_copy.xlsx", first


********************************************************************************
* ASSIGN VALUES, ADD LABELS TO VARIABLES, AND CHECK DATA *
********************************************************************************

* Sort dataset in descending order by these variables.
sort participant_id group 

* Destring and label 'participant_id' variable.
replace participant_id = subinstr(participant_id, "sub-", "", .) // Remove 'sub-' prefix from participant_id
	destring participant_id, replace // Convert string to byte
tab participant_id, missing // Check participant IDs.

* Destring and label 'sex' variable.
tab sex, missing // Frequency table of raw 'Sex' variable
	replace sex = "0" if sex == "Female" // Replace 'Female' with string '0'
	replace sex = "1" if sex == "Male" // Replace 'Male' with string '1'
	destring sex, replace // Convert string to byte
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

* Destring and label 'group' variable.
tab group, missing
	replace group = "0" if group == "Sham" 
	replace group = "1" if group == "Real"
	destring group, replace
	lab def groupl 0 "Sham" 1 "Real"
	lab val group groupl
	lab var group "Stimulation type"
tab group, missing

* Destring and label 'session_id' variable.
tab session_id, missing
	replace session_id = "0" if session_id == "ses-pre" 
	replace session_id = "1" if session_id == "ses-post1"
	destring session_id, replace
	lab def session_idl 0 "Pre" 1 "Post1"
	lab val session_id session_idl
tab session_id, missing

* Check participant Age.
tab age, missing
sum age, detail

* Check participant Years Since Diagnosis.
tab years_since_dx, missing
sum years_since_dx, detail

* Check baseline (ses-pre) clinical symptom scores.
tab symptom_score_madrs if session_id == 0, missing // Check frequency of 'Pre' session_id symptom scores
sum symptom_score_madrs if session_id == 0, detail // Check summary data of 'Pre' session_id symptom scores

* Check outcome (ses-post1) clinical symptom scores.
tab symptom_score_madrs if session_id == 1, missing
sum symptom_score_madrs if session_id == 1, detail 

* Count observations (rows) in dataset.
count

* Save dataset
save "usedata/NIBS-DAS_clinical_exampledata_long.dta", replace // Save data (as .dta file)


********************************************************************************
* RESHAPE WIDE EXAMPLE
********************************************************************************
/* Some analyses require your dataset to be in "wide" format to be performed.
* You can reshape your data "wide" using the below code. */

* Reshape data "wide".
reshape wide symptom_score_madrs, i(participant_id) j(session_id) 
/* Note: This removes the 'session_id' variable and reshapes the 'symptom_score_madrs' variable 
into separate variables for Pre and Post1 session_ids. */

* Rename 'symptom_score_madrs' variable with unique labels after reshaping.
rename symptom_score_madrs0 symptom_score_pre 	// Relabel 'symptom_score_madrs0' to 'symptom_score_pre' 
rename symptom_score_madrs1 symptom_score_post1 	// Relabel 'symptom_score_madrs1' to 'symptom_score_post1' 

* Reorder the variables.
order participant_id diagnosis age sex handedness years_of_education years_since_dx rmt_intensity group symptom_score_pre symptom_score_post1 ManufacturerModelName protocol_name tms_pos_centre pulse_rate pulse_intensity_rmt
* Save reshaped dataset
save "usedata/NIBS-DAS_clinical_exampledata_wide.dta", replace 


********************************************************************************
* RESHAPE LONG EXAMPLE
********************************************************************************
/*You can reshape your data back to the original ("long") layout using the below code. */

* Rename variables for reshape. 
* Note: variables need to begin with the same 'stub' prior to reshaping. 
	* This renames the pre- and post- symptom score variable to the stub 'symptom_score_madrs'. 
	rename symptom_score_pre symptom_score_madrs0 // Relabel 'symptom_score_pre' variable to 'symptom_score_madrs0'
	rename symptom_score_post1 symptom_score_madrs1 // Relabel 'symptom_score_post1' variable to 'symptom_score_madrs1'

*Reshape data long.
/*	Note: the above reshapes what were previously two columns with the names 
	'Pre' and 'Post1' into a single variable named 'symptom_score_madrs', which 
	will be a DV, and creates a new variable named 	'session_id', to be used as 
	an IV in our upcoming analyses. 
*/
reshape long symptom_score_madrs, i(participant_id) j(session_id)

* Reorder the variables.
order participant_id diagnosis age sex handedness years_of_education years_since_dx rmt_intensity group session_id symptom_score_madrs ManufacturerModelName protocol_name tms_pos_centre pulse_rate pulse_intensity_rmt


********************************************************************************
* COMBINING MULTIPLE DATASETS * 
********************************************************************************
/* Multiple datasets can be combined using the append function of STATA, as shown in the below additional example code. */

/* Note: When combining studies, study and participant numbers need to be unique. Here, we assign a 'study id number'  
prefix to each participant id number (e.g., st01_ or st02_) to designate which dataset each participant 
is from. We also generate a new variable 'study_id_number' which can be used in analyses to 
examine differences between studies.*/

* Call and prepare first dataset for append
use "usedata/NIBS-DAS_clinical_exampledata_long.dta", clear  // Load first dataset
	gen study_id = 1  // Generate variable numbering this the first dataset
	gen study_participant_id = "st-01_sub-" + string(participant_id) // Generate new variable study_participant_id to give a unique id for studies/subjects in appended dataset.
	order study_id participant_id study_participant_id
save "usedata/NIBS-DAS_clinical_exampledatafile_1.dta", replace // Save datafile

* Call and prepare second dataset for append
use "usedata/NIBS-DAS_clinical_appenddata.dta", clear  // Load second dataset (previously cleaned as per above steps)
	replace participant_id = subinstr(participant_id, "sub-", "", .) // Remove 'sub-' prefix from participant_id
	destring participant_id, replace // Convert string to byte
	tab participant_id, missing // Check participant IDs.
	gen study_id = 2  // Generate variable numbering this the second dataset
	gen study_participant_id = "st-02_sub-" + string(participant_id) // Generate new variable study_participant_id to give a unique id for studies/subjects in appended dataset.
	order study_id participant_id study_participant_id
save "usedata/NIBS-DAS_clinical_exampledatafile_2.dta", replace // Save datafile

* Append datasets
use "usedata/NIBS-DAS_clinical_exampledatafile_1.dta", clear  // Load first datafile
append using "usedata/NIBS-DAS_clinical_exampledatafile_2.dta" // Append second datafile to first

* Check summary statistics to confirm datafiles have appended correctly
duplicates report study_participant_id // Report any duplicated study_participant_id numbers
count // Count observations (rows) in dataset.
describe // Describe variables in combined dataset

* Save combined dataset (as .dta)
save "usedata/NIBS-DAS_clinical_exampledatafile_combined.dta", replace
* Remove unnecessary files
rm "usedata/NIBS-DAS_clinical_exampledatafile_1.dta"
rm "usedata/NIBS-DAS_clinical_exampledatafile_2.dta"

********************************************************************************
* END OF SCRIPT *
********************************************************************************
