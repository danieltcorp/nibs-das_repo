# **NIBS-DAS repository files v1.0**


## **This document provides an overview of the files contained within this repo, and explains the folder and file structure.** ##


‘NIBS data analysis structure’ (NIBS-DAS) is a template pipeline for the layout and management of collated NIBS data to facilitate data sharing and statistical analysis. 

NIBS-DAS is focused on collated data. Therefore, within the `nibs-das_examples` folder, files are formatted in NIBS-DAS and demonstrate the NIBS-DAS pipeline. There are two example experiments: an rTMS clinical trial (`nibs-das_examples/clinical_example`) and a TMS study collecting motor evoked potentials (`nibs-das_examples/mep_example`). 

Within the `uncollated_data_examples` folder, we also provide the corresponding raw, uncollated datafiles for these two example experiments. These are not in NIBS-DAS format (because NIBS-DAS focuses on collated data), but instead follow current NIBS-BIDS formatting (<https://github.com/nigelrogasch/nibs-bids/tree/master/nibs-bids-v6>). These are only broad templates and users should always follow NIBS-BIDS guidelines and updates for how to format data in this structure, rather than our files here.

While the formatting of uncollated raw data is not our explicit aim, these files provide context for how the data goes from its raw uncollated format, to the NIBS-DAS collated format. Further, any dataset uploaded to bignibsdata.com needs to contain metadata files describing the data. The aim of NIBS-DAS is not to provide guidance on metadata formatting, yet here we show how this can be achieved following NIBS-BIDS guidelines. To this end, the metadata files for both the example studies can be found within the `uncollated_data_examples` folder, within the study root directory for study level data, and in subject folders for subject level data.

As a result, the folders and files within this repo show how these two formats can be integrated into an overarching project folder containing both the raw, uncollated data (NIBS-BIDS) and collated data (NIBS-DAS), for any NIBS experiment. For example, for the clinical dataset, the folder structure could be: 

```text
clinical_example/
├── participant_data/
└── collated_participant_data/
```

One can replace `clinical_example` with their project name (e.g. `tFUS_PD_feasibility`) and upload this project file to <https://bignibsdata.com>, containing both the uncollated and collated data with full metadata. See the repo for example subfolders in this structure.


### **Elaboration on the NIBS-DAS template folder structure** ###

The NIBS-DAS file structure (`nibs-das_examples/clinical_example/collated_participant_data` and `nibs-das_examples/mep_example/collated_participant_data`) is designed to help with  file organisation, tracking of operations, and version control. Below, we elaborate on the workflow in our template to allow users to apply this to their own research projects. 

- The spreadsheet (or csv/tsv if preferred) (e.g., `clinical_exampledata_2025-12-13.xlsx`) contains the data that has been collated from the raw data files. The layout is described in the manuscript, and is ready to be imported into statistical software.

- The `usedata` folder is used to store a copy of the collated participant data (e.g., `clinical_exampledata_2025-12-13_copy.xlsx`) and is the location from which the data are read into statistical software for manipulation and analysis. The data within these spreadsheets should not be manipulated, overwritten, or deleted. All operations/calculations can be done after importing this spreadsheet into statistical software. All files produced by operations within statistical software, for example after manipulating the layout of the data to enable alternative statistical analyses (e.g., `clinical_exampledata_wide.dta`), are also saved within the `usedata` folder.

- The `code` folder stores any scripting files being used for data management (e.g., `clinical_dm_R_2025-12-11.R`) or data analysis (e.g., `clinical_da_R_2025-12-11.R`) of collated data.

- The `outputfiles` folder is used to store outputs from analyses performed of the data, for example, graphs or figures.

- Within folder there is a sub-folder named `old`, where the user can store older versions of files when they are no longer being used. This ensures data are not deleted if you need to come back to an older version of the data or analysis script. Files are dated using the `YYYY-MM-DD` format to facilitate version control.

