# Longitudinal Public Health Data Analysis
---
This project was part of the March 2025 [CMU Hackathon](https://guides.library.cmu.edu/hackathon "CMU Hackathon") in partnership with [DNAnexus](https://www.dnanexus.com "DNAnexus").

![DNANEXUSLOGO](https://github.com/user-attachments/assets/422aa273-195f-45f0-8bf0-4e846ded0d02)

---

## Problem: Increased availability of large EHRs with limited accessible causal discovery methods  

With the increasing availability of multimodal patient data, non-specialists, including health care professionals, are obtaining an abundance of transdisciplinary information without a corresponding ability to analyze and interpret it. Traditional statistical methods primarily focus on correlation-based associations, making it difficult to infer causal mechanisms in complex patient trajectories. Working with raw EHR data presents several challenges that must be addressed for effective causal discovery. 
This study presents a computational pipeline that can utilize large EHR datasets, provide approachable user inputs, run more efficient causal analysis, and output more accessible visualizations. We created a causal discovery pipeline for use with the carevue subset of the [MIMIC-III Dataset](https://mimic.mit.edu/ "MIMIC-III Dataset")[Johnson et al., 2022]. Custom R and command line scripts were written and run on [DNAnexus](https://www.dnanexus.com "DNAnexus") and use Tetrad [Tetrad](https://www.cmu.edu/dietrich/philosophy/tetrad/#:~:text=Tetrad%20is%20a%20software%20suite,via%20R%20with%20Rpy%2DTetrad "Tetrad") for causal analysis. Users define parameters of the causal search and our pipeline automates the data preprocessing steps, causal search, and data output visualization.

---

## What is Tetrad 

Tetrad [Tetrad](https://www.cmu.edu/dietrich/philosophy/tetrad/#:~:text=Tetrad%20is%20a%20software%20suite,via%20R%20with%20Rpy%2DTetrad "Tetrad") is a software suite for simulating, estimating, and searching for graphical causal models of statistical data. The aim of the program is to provide sophisticated methods in a friendly interface requiring very little statistical sophistication of the user and no programming knowledge. Tetrad is open-source, free software that performs many of the functions in commercial programs.

[See here for Tetrad User Manual](https://htmlpreview.github.io/?https:///github.com/cmu-phil/tetrad/blob/development/tetrad-lib/src/main/resources/docs/manual/index.html "See here for Tetrad User Manual")

 
---
## Pipeline Workflow:
![Pipeline_NewFlowChart_03 25](https://github.com/user-attachments/assets/5b44d810-d4a6-4336-9daf-7fea3a0a4be9)



----
## Installation Prior to Pipeline
### Latest Java Version 
`sudo apt install openjdk-17-jdk`

More information regarding Java installation can be found [HERE](https://www.java.com/en/download/help/download_options.html "HERE")
***
### Latest R Versin 
`sudo apt install r-base`

More information regarding R installatin can be found [HERE](https://rstudio-education.github.io/hopr/starting.html "HERE!") 
***
### .jar file for running Causaml-cmd on terminal (Tetrad command line option) 
`wget https://s01.oss.sonatype.org/content/repositories/releases/io/github/cmu-phil/causal-cmd/1.12.0/causal-cmd-1.12.0-jar-with-dependencies.jar`


## Files Needed Prior to Pipeline 
### YAML file to specify variables (eg specific columns) and specific arguments to input into Tetrad
##### Please see [Example User Input Folder](https://github.com/collaborativebioinformatics/Longitudinal_emr_accleRation/tree/main/example_user_input "Example User Input Folder") for example R script to output this file and example of file format. 
---
### Knowledge File 

