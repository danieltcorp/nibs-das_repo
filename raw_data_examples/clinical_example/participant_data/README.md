# NIBS-DAS Clinical rTMS Example Dataset


## Overview

- **Project name**: NIBS-DAS Clinical rTMS Example Dataset
- **Project years**: 2025
- **Brief overview**:  
  This dataset represents an example clinical trial of high-frequency repetitive transcranial magnetic stimulation (rTMS) applied to the left dorsolateral prefrontal cortex (DLPFC) for patients with major depressive disorder (MDD). The purpose is to provide a dataset to demonstrate the NIBS-DAS pipeline.   
- **Description of dataset contents**:  
  - `participants.tsv` contains participant demographics.  
  - `phenotype/` contains clinical diagnoses, outcome scales, and medications.
  - `sub-*` folders contain nibs data.  
- **Independent variables**:  
  - group (real vs sham rTMS)  
  - session (ses-pre vs ses-post1)  
- **Dependent variables**:  
  - madrs scores  
- **Control variables**:  
  - Age
  - Sex
- **Quality assessment**:  

---

## Methods

### Subjects
- **Recruitment**: n/a  
- **Inclusion criteria**: Diagnosis of major depressive disorder (MDD).  
- **Exclusion criteria**: Standard TMS safety exclusions

### Apparatus
- rTMS delivered using a MagVenture MagPro R30 stimulator using a figure-8 coil.  
- Coil positioned over left DLPFC  

### Initial setup
- RMT determined from motor cortex stimulation.    

### Study organization
- rTMS intervention  
- Pre- and Post-intervention clinical assessments (madrs).  

### Study details
- rTMS applied at 10 Hz, 120% RMT, left DLPFC.  
- Sham condition applied at same parameters with sham coil. 

### Additional data acquired
- Clinical scales: madrs.
- Additional diagnoses
- Medications
- Years of education
- Patient demographics 

### Experimental location
- n/a

### Missing data
- n/a

### Notes
- Dataset is for demonstration only.  
- Intended to illustrate NIBS-DAS
