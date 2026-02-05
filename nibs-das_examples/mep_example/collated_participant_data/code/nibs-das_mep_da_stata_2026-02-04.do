/*******************************************************************************
Do-file title: nibs-das_mep_da_stata_2026-02-04.do   		 

Stata code file demonstrating principles of data analysis (da) of a fictional neurophysiological (e.g., TMS MEP) NIBS dataset: 
"NIBS-DAS_mep_exampledata_2026-02-04_copy.xlsx". 

Dataset prepared for analyses performed in the corresponding data management code file: 
"nibs-das_mep_dm_stata_2026-02-04.do"

Demonstrates example analyses which:
(i) measure MEP amplitudes in different muscles (FDI, APB)
(ii) compare SICI between muscles using mixed effects models

*******************************************************************************/

clear all 
capture log close
set more off
version 17.0


********************************************************************************
* EXAMPLE A - ANALYSIS OF SICI IN FDI AND APB MUSCLES SEPARATELY *
********************************************************************************

*Set your working directory
cd "[YourFilePath]/nibs-das_examples/mep_example/collated_participant_data"

* This analysis requires a dataset layout where MEPs from FDI and APB muscles are separate variables.

* Open file
use "usedata/nibs-das_mep_exampledata_blockmean.dta", clear

* MEP Example A1: is SICI present in the FDI muscle, adjusting for age, sex, and pre-stimulus EMG activity?
mixed mep_ampl_fdi c.age i.sex c.pre_rms_fdi i.tms_stim_mode || participant_id:, base noretable
contrast i.tms_stim_mode // Signifcance of 'tms_stim_mode' main effect. 
margins i.tms_stim_mode // Show marginal means for each level of trial type (single; dual)
marginsplot, ylabel(0(.2)1.2) ytitle("MEP amplitude (mV): FDI") /// Generate plot of estimated marginal means
	title("Analysis of SICI in FDI muscle")
	
* MEP Example A2: is SICI present in the APB muscle, adjusting for age and sex, and pre-stimulus EMG activity? 
mixed mep_ampl_apb c.age i.sex c.pre_rms_apb i.tms_stim_mode || participant_id:, base noretable
contrast i.tms_stim_mode
margins i.tms_stim_mode
marginsplot, ylabel(0(.2)1.2) ytitle("MEP amplitude (mV): APB") ///
	title("Analysis of SICI in APB muscle")

	
********************************************************************************
* EXAMPLE B - ANALYSIS OF SICI BETWEEN FDI AND APB MUSCLES *
********************************************************************************
/* To analyse SICI by muscle, need to have data in a 'long' format containing a variable denoting which muscle each MEP was 
measured from. Using the dataset previously reshaped into this layout, we can now include 'muscle' as an IV in the analyses. 
For example: */ 

* Open file
use "usedata/nibs-das_mep_exampledata_blockmean_long.dta", clear

/* MEP Example B: Is there a difference in SICI between FDI and APB muscles, adjusting for age, sex, and pre-stimulus EMG activity? */

mixed mep_ampl c.age i.sex c.pre_rms i.tms_stim_mode##i.muscle || participant_id:, base noretable
contrast i.tms_stim_mode##i.muscle // Significance of overall interaction effect. 
margins i.tms_stim_mode#i.muscle // Show marginal means for each level of interaction between trial type and muscle
marginsplot, ytitle("MEP amplitude (mV)") /// Generate plot of estimated marginal means
	title("Comparison of SICI in FDI and APB muscles")
graph export "outputfiles/nibs-das_mep_questionB_figure_stata.png", replace // Save plot


********************************************************************************
* END OF SCRIPT *
********************************************************************************