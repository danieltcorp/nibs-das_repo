/*******************************************************************************
Do-file title   NIBS-DAS_mep_da_stata_2025-12-11.do   		 

Stata code file demonstrating principles of data analysis (da) of a fictional neurophysiological (e.g., TMS MEP) NIBS dataset: 
"NIBS-DAS_mep_exampledata_2025-12-11_copy.xlsx". 

Dataset prepared for analyses performed in the corresponding data management code file: 
"NIBS-DAS_mep_dm_stata_2025-12-11.do"

Demonstrates example analyses which:
(i) measure MEP amplitudes in different muscles (FDI, APB) using linear regression
(ii) compare MEP amplitudes between muscles using mixed effects models.

*******************************************************************************/

clear all 
capture log close
set more off
*version 17.0
version 15.0


********************************************************************************
* EXAMPLE A - ANALYSIS OF SICI IN FDI AND APB MUSCLES SEPARATELY *
********************************************************************************

*cd "[YourFilePath]/NIBS-DAS_mep_example/collated_participant_data"
cd "/Users/danielcorp/Dropbox/2016_BigTMSdata/0_Projects/0_2023_NIBS-DAS/NewFolderStructure_Oct25/FolderStructure_2025-12-16_DC/NIBS-DAS_mep_example/collated_participant_data"

/* This analysis requires a 'wide' dataset layout. */

* Open file
use "usedata/NIBS-DAS_mep_exampledata_meanblock_wide.dta", clear

/* MEP Example Question 1: is SICI present in the FDI muscle, adjusting for age, sex, and pre-stimulus EMG activity? */ 
regress mep_ampl_fdi c.age i.sex c.pre_rms_fdi i.tms_stim_mode 
contrast i.tms_stim_mode
margins i.tms_stim_mode
marginsplot, ylabel(0(.2)1.2) ytitle("MEP amplitude (mV): FDI") ///
	title("Analysis of SICI in FDI muscle")
	

/* MEP Example Question 2: is SICI present in the APB muscle, adjusting for age and sex? */ 
regress mep_ampl_apb c.age i.sex c.pre_rms_apb i.tms_stim_mode
contrast i.tms_stim_mode
margins i.tms_stim_mode
marginsplot, ylabel(0(.2)1.2) ytitle("MEP amplitude (mV): APB") ///
	title("Analysis of SICI in APB muscle")
	

********************************************************************************
* EXAMPLE B - ANALYSIS OF SICI BETWEEN FDI AND APB MUSCLES *
********************************************************************************
/* To analyse SICI by muscle, need to have data in 'long' format. Using the dataset previously 
reshaped into this layout, we can now include 'muscle' as an IV in the analyses. For example: */ 

* Open file
use "usedata/NIBS-DAS_mep_exampledata_meanblock_long.dta", clear

/* MEP Example Question 3: is there a significant difference in SICI between FDI 
and APB muscles, adjusting for age, sex, and pre-stimulus EMG activity? */
mixed mep_ampl c.age i.sex c.pre_rms i.tms_stim_mode##i.muscle || participant_id:, base noretable
contrast i.tms_stim_mode##i.muscle // Signifcance of overall interaction effect. 
margins i.tms_stim_mode#i.muscle // Show marginal means for each level of interaction between trial type and muscle
marginsplot, ytitle("MEP amplitude (mV)") ///
	title("Comparison of SICI in FDI and APB muscles")
graph export "outputfiles/NIBS-DAS_mep_question3_figure_stata.tif", replace


********************************************************************************
* END OF SCRIPT *
********************************************************************************
