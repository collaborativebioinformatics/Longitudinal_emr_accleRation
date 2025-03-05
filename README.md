# Rapid Longitudinal Analysis of Public Health Data 
---
This project was part of the March 2025 [CMU Hackathon](https://guides.library.cmu.edu/hackathon "CMU Hackathon") in partnership with [DNAnexus](https://www.dnanexus.com "DNAnexus").
Hackathon Team: Samuel Blechman, Nicholas P. Cooley, Aung Myat Phyo, Ciara O'Donoghue, Glenn Ross-Dolan, Rebecca Satterwhite, Rishika Gupta


![DNANEXUSLOGO](https://github.com/user-attachments/assets/422aa273-195f-45f0-8bf0-4e846ded0d02)

---

## Problem: Increased availability of large EHRs with limited accessible causal discovery methods  

With the increasing availability of multimodal patient data, non-specialists, including health care professionals, are obtaining an abundance of transdisciplinary information without a corresponding ability to analyze and interpret it. Traditional statistical methods primarily focus on correlation-based associations, making it difficult to infer causal mechanisms in complex patient trajectories. Working with raw EHR data presents several challenges that must be addressed for effective causal discovery. 
To address these challenges, we present a causal discovery pipeline designed to automate the preprocessing, causal inference, and visualization steps required for analyzing longitudinal data, using [MIMIC-III Dataset](https://mimic.mit.edu/ "MIMIC-III Dataset")[Johnson et al., 2022] as an example. Our approach leverages [DNAnexus](https://www.dnanexus.com "DNAnexus") for scalable computation and employs [Tetrad](https://www.cmu.edu/dietrich/philosophy/tetrad/#:~:text=Tetrad%20is%20a%20software%20suite,via%20R%20with%20Rpy%2DTetrad "Tetrad") [Ramsey et al. 2018], a well-established causal discovery tool, to identify relationships between clinical features, laboratory results, microbiological events, and patient outcomes. By converting raw CSVs into an SQL database, we ensure efficient querying and data retrieval.


---

## What is Tetrad 

Tetrad [Tetrad](https://www.cmu.edu/dietrich/philosophy/tetrad/#:~:text=Tetrad%20is%20a%20software%20suite,via%20R%20with%20Rpy%2DTetrad "Tetrad") is a software suite for simulating, estimating, and searching for graphical causal models of statistical data. The aim of the program is to provide sophisticated methods in a friendly interface requiring very little statistical sophistication of the user and no programming knowledge. Tetrad is open-source, free software that performs many of the functions in commercial programs.

[See here for Tetrad User Manual](https://htmlpreview.github.io/?https:///github.com/cmu-phil/tetrad/blob/development/tetrad-lib/src/main/resources/docs/manual/index.html "See here for Tetrad User Manual")

---

## What is [DNAnexus](https://www.dnanexus.com "DNAnexus") 

![DNAnexususes](https://github.com/user-attachments/assets/82196058-035f-4e75-8c85-93d44c5939e1)

 
---
## Pipeline Workflow:
![Pipeline_NewFlowChart_03 25](https://github.com/user-attachments/assets/5b44d810-d4a6-4336-9daf-7fea3a0a4be9)



----
## Installation Prior to Pipeline
### Latest Java Version 
`sudo apt install openjdk-17-jdk`

More information regarding Java installation can be found [HERE](https://www.java.com/en/download/help/download_options.html "HERE")
***
### Latest R Version 
`sudo apt install r-base`

More information regarding R installatin can be found [HERE](https://rstudio-education.github.io/hopr/starting.html "HERE!") 
***
### .jar file for running Causaml-cmd on terminal (Tetrad command line option) 
`wget https://s01.oss.sonatype.org/content/repositories/releases/io/github/cmu-phil/causal-cmd/1.12.0/causal-cmd-1.12.0-jar-with-dependencies.jar`


# Files Needed Prior to Pipeline 
### YAML file to specify variables (eg specific columns) and specific arguments to input into Tetrad

#### Please see [Example User Input Folder](https://github.com/collaborativebioinformatics/Longitudinal_emr_accleRation/tree/main/example_user_input "Example User Input Folder") for example R script: [GenerateExampleUserInput.R](https://github.com/collaborativebioinformatics/Longitudinal_emr_accleRation/blob/main/example_user_input/GenerateExampleUserInput.R "GenerateExampleUserInput.R") to output this file and [user_input_yaml.txt](https://github.com/collaborativebioinformatics/Longitudinal_emr_accleRation/blob/main/example_user_input/user_input_yaml.txt "user_input_yaml.txt") for example of file format. NOTE-examples of specific arguments and options can be found in the R script file. 
---
### Knowledge File 

To add knowledge parameters the user must create a `knowledge.txt` file. This option enables the user to input background knowledge regarding the data. For example. information about the time order of the measured variables. Please see ['knowledge.txt'](https://github.com/collaborativebioinformatics/Longitudinal_emr_accleRation/blob/main/example_user_input/knowledge.txt "knowledge.txt") for reference. 

---
# Testing

We tested use of our pipeline through data from the [MIMIC-III Dataset](https://mimic.mit.edu/ "MIMIC-III Dataset")[Johnson et al., 2022]. 

--- 

# Reproducibility and Future Directions 

This pipeline has the potential to be developed for the use of biological data (e.g. exploring causal relationships in a dataset with SNPs and gene expression). Furthermore, the use of principal component analysis may provide more efficiency to a large data set without as much user input. 



