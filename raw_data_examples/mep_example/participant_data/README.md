# NIBS-DAS Motor Evoked Potential Example Dataset


## Overview

- **Project name**: NIBS-DAS Motor Evoked Potential Example Dataset
- **Project years**: 2025
- **Brief overview**:  
  This dataset represents an example study of transcranial magnetic stimulation (TMS) applied to the left motor cortex in healthy subjects, measuring motor evoked potentials with single and paired-pulses, measuring short-interval intracortical inhibition (SICI). The purpose is to provide a dataset to demonstrate the NIBS-DAS pipeline.   
- **Description of dataset contents**:  
  - `participants.tsv` contains participant demographics.  
  - `sub-*` folders contain nibs and emg meta/data.
  - `sourcedata` contains emg data as originally outputted by Labchart software (then converted to common .edf format, stored within `sub-*` folders)
- **Independent variables**:  
  - tms_stim_mode (dual vs. single pulse MEPs)  
  - muscle (FDI vs APB)  
- **Dependent variables**:  
  - mep_ampl (MEP amplitudes) 
- **Control variables**:  
  - Age
  - Sex
  - pre_rms (pre stimulus root mean square EMG activity)
- **Quality assessment**:  

---

## Methods

### Subjects
- **Recruitment**: n/a  
- **Inclusion criteria**: Standard inclusions 
- **Exclusion criteria**: Standard TMS safety exclusions

### Apparatus
- TMS delivered with Magstim 200 BiStim2 stimulator using a figure-8 coil.  
- Coil positioned over left M1  
- Test (single) TMS pulses applied at 120% RMT and conditioning pulses applied at 80% RMT
- MEPs measured from FDI and APB muscles using surface EMG.  

### Initial setup
- RMT determined from motor cortex stimulation.    

### Study organisation
- SICI experiment   

### Study details
 
### Additional data acquired

### Experimental location
- n/a

### Missing data
- n/a

### Notes
- Dataset is for demonstration only.  
- Intended to illustrate NIBS-DAS
