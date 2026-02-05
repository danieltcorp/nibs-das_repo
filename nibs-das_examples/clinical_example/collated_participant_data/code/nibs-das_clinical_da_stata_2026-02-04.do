/*******************************************************************************
Do-file title: nibs-das_clinical_da_stata_2026-02-04.do   		 
 
Stata code file demonstrating principles of data analysis (da) on a fictional clinical NIBS dataset: 
"nibs-das_clinical_exampledata_2026-02-04_copy.xlsx". 

Dataset prepared for these analyses using the corresponding data management (dm) code file: 
"nibs-das_clinical_dm_stata_2026-02-04.do"

Demonstrates example analyses which:
(i) compare clinical symptom scores between active and sham NIBS conditions
(ii) compare clinical symptoms scores between active and sham NIBS conditions using a symptom change percentage
(iii) analyse a combined, multi-study ('big') dataset
 
*******************************************************************************/

clear all 
capture log close
set more off
version 17.0

********************************************************************************
* EXAMPLE A - ANALYSIS OF SYMPTOM SCORES BETWEEN CONDITIONS *
********************************************************************************

*Set your working directory
cd "[YourFilePath]/nibs-das_examples/clinical_example/collated_participant_data"

* Analyse the effect of active and sham NIBS conditions on symptom scores over time. This requires a 'long' dataset layout. */

* Open data
use "usedata/nibs-das_clinical_exampledata_long.dta", clear

* Clinical Example A1: Is there a difference in symptom scores over time between active and sham NIBS conditions, adjusting for age and sex?
mixed symptom_score_madrs c.age i.sex i.session_id##i.group || participant_id:, noretable
contrast i.session_id##i.group // Significance of overall interaction effect.
margins i.session_id#i.group  // Show marginal means for each level of interaction between session_id and group
marginsplot, ytitle("MADRS symptom scores")
graph export "outputfiles/nibs-das_clinical_exampleA1_figure_stata.png", replace // Generate and export graph 


/* You may also want to analyse the effect of the rTMS using symptom change percentage as the dependent variable. Here, we can call the "wide" dataset and use standard linear multiple regression. */

* Open data
use "usedata/nibs-das_clinical_exampledata_wide.dta", clear // Import 'wide' dataset containing a symptom percentage change ('pct_change') variable

* Clinical Example A2: Is there a significant symptom score improvement over time between active and sham NIBS conditions, adjusting for age and sex?
regress pct_change c.age i.sex i.group, base
contrast i.group
margins i.group
marginsplot, recast(scatter) ytitle("MADRS symptom improvement (%)")
graph export "outputfiles/nibs-das_clinical_exampleA2_figure_stata.png", replace // Generate and export graph


********************************************************************************
* EXAMPLE B - ANALYSIS OF SYMPTOM SCORES ACROSS MULTIPLE CLINICAL TRIALS *
********************************************************************************
* You can perform analyses of data combined from multiple studies (i.e., 'big data' analyses) using an appended dataset.

* Open file
use "usedata/nibs-das_clinical_exampledata_combined.dta", clear // Import 'appended' dataset containing data combined from multiple studies

* Clinical Example B: Is there a difference in symptom scores over time between active and sham NIBS conditions, adjusting for age and sex, across studies? 
mixed symptom_score_madrs c.age i.sex i.study_id i.session_id##i.group || study_participant_id:, noretable 
contrast i.session_id##i.group // Significance of overall interaction effect.
margins i.session_id#i.group  // Show marginal means for each level of interaction between session_id and group
marginsplot, ytitle("MADRS symptom scores")
graph export "outputfiles/nibs-das_clinical_exampleB_figure_stata.png", replace // Generate and export graph

/* Note: The above analysis is a mixed model with unique identifier study_participant_id as random factor. Here, study_id is a fixed 
effect because the number of combined studies is low. Where a greater number of studies are combined, study_id can be a random factor. */


********************************************************************************
* END OF SCRIPT *
********************************************************************************