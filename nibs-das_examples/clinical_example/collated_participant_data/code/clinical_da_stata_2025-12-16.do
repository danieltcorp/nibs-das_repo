/*******************************************************************************
Do-file title   NIBS-DAS_clinical_da_stata_2025-12-16.do   		 
 
Stata code file demonstrating principles of data analysis (da) on a fictional clinical NIBS dataset: 
"NIBS-DAS_clinical_exampledata_2025-12-11_copy.xlsx". 

Dataset prepared for these analyses using the corresponding data management (dm) code file: 
"NIBS-DAS_clinical_dm_stata_2025-12-11.do"

Demonstrates example analyses which:
(i) compare clinical symptom scores between NIBS conditions (e.g., active versus sham)
(ii) analyse a combined, multi-study ('big') dataset
 
*******************************************************************************/

clear all 
capture log close
set more off
*version 17.0
version 15.0


********************************************************************************
* EXAMPLE A - ANALYSIS OF SYMPTOM SCORES BETWEEN CONDITIONS *
********************************************************************************

*cd "[YourFilePath]/NIBS-DAS_clinical_example/collated_participant_data"
cd "/Users/danielcorp/Dropbox/2016_BigTMSdata/0_Projects/0_2023_NIBS-DAS/NewFolderStructure_Oct25/FolderStructure_2025-12-16_DC/NIBS-DAS_clinical_example/collated_participant_data"

/* This analysis requires a 'long' dataset layout. */

* Open file
use "usedata/NIBS-DAS_clinical_exampledata_long.dta", clear

* Clinical Example Question 1: is there a significant difference in pre and post TMS symptom scores between active and sham NIBS conditions, adjusting for age and sex? */
mixed symptom_score_madrs c.age i.sex i.session_id##i.group || participant_id:, noretable
contrast i.session_id##i.group // Significance of overall interaction effect.
margins i.session_id#i.group  // Show marginal means for each level of interaction between session_id and group
marginsplot, ytitle("MADRS symptom scores")
graph export "outputfiles/NIBS-DAS_clinical_question1_figure_stata.tif", replace // Generate and export graph


********************************************************************************
* EXAMPLE B - ANALYSIS OF SYMPTOM SCORES ACROSS MULTIPLE CLINICAL TRIALS *
********************************************************************************
/* You can perform analyses of data combined from multiple studies using an appended dataset. */

* Open file
use "usedata/NIBS-DAS_clinical_exampledatafile_combined.dta", clear // Import 'appended' dataset containing data combined from multiple separate studies

* Clinical Example Question 2: is there a significant difference in pre and post TMS symptom scores between active and sham NIBS conditions, adjusting for age and sex, across studies? 
/* Mixed model with uniqie identifier study_participant_id as random factor. Here, study_id is a fixed 
 effect because the number of combined studies is low. Where a greater number of studies are combined, study_id can be a random factor */
mixed symptom_score_madrs c.age i.sex i.study_id i.session_id##i.group || study_participant_id:, noretable 
contrast i.session_id##i.group // Significance of overall interaction effect.
margins i.session_id#i.group  // Show marginal means for each level of interaction between session_id and group
marginsplot, ytitle("MADRS symptom scores")
graph export "outputfiles/NIBS-DAS_clinical_question2_figure_stata.tif", replace // Generate and export graph

********************************************************************************
* END OF SCRIPT *
********************************************************************************
