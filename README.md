# Rapid Longitudinal Analysis of Public Health Data 
---
This project was part of the March 2025 [CMU Hackathon](https://guides.library.cmu.edu/hackathon "CMU Hackathon") in partnership with [DNAnexus](https://www.dnanexus.com "DNAnexus").

Hackathon Team: Samuel Blechman, Nicholas P. Cooley, Aung Myat Phyo, Ciara O'Donoghue, Glenn Ross-Dolan, Rebecca Satterwhite, Rishika Gupta

[Link to Slides](https://docs.google.com/presentation/d/1F4aR2k4DV_tZEG4hxpom6pa1bV6Nki_9co9QydmIfV4/edit#slide=id.g33cb141f22f_5_10 "Link to Slides")


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

# Results 
![example_output](https://github.com/user-attachments/assets/26955ac9-fa95-4e18-aa03-8bcd4e23dfdf)

Results in example_output_name_out.txt. 87 causal relationships identified.

================================================================================
Graph Edges:
1. "LAB_AlkalinePhosphatase" o-> "LAB_Bilirubin.Total"
2. "LAB_AlkalinePhosphatase" --> "LAB_Calcium.Total"
3. "LAB_AlkalinePhosphatase" --> "LAB_Sodium"
4. "LAB_AnionGap" <-> "LAB_Bicarbonate"
5. "LAB_AnionGap" <-> "LAB_Creatinine"
6. "LAB_AnionGap" <-> "LAB_Lactate"
7. "LAB_AnionGap" <-> "LAB_Phosphate"
8. "LAB_AsparateAminotransferase.AST." --> "LAB_AlanineAminotransferase.ALT."
9. "LAB_Basophils" o-> "LAB_Eosinophils"
10. "LAB_Bicarbonate" <-> "LAB_Chloride"
11. "LAB_Bicarbonate" <-> "mortality_in_hospital"
12. "LAB_Calcium.Total" <-> "LAB_CreatineKinase.CK."
13. "LAB_Calcium.Total" --> "LAB_Lymphocytes"
14. "LAB_Calcium.Total" <-> "LAB_Magnesium"
15. "LAB_Calcium.Total" --> "LAB_Monocytes"
16. "LAB_CalculatedTotalCO2" o-> "LAB_BaseExcess"
17. "LAB_CalculatedTotalCO2" o-> "LAB_Bicarbonate"
18. "LAB_CalculatedTotalCO2" o-> "LAB_pCO2"
19. "LAB_Creatinine" <-> "LAB_UreaNitrogen"
20. "LAB_Eosinophils" <-> "LAB_Neutrophils"
21. "LAB_Eosinophils" <-> "LAB_PlateletCount"
22. "LAB_Eosinophils" <-> "mortality_in_hospital"
23. "LAB_Hematocrit" o-> "LAB_Hemoglobin"
24. "LAB_Hematocrit" o-> "LAB_Phosphate"
25. "LAB_Hemoglobin" --> "LAB_Lymphocytes"
26. "LAB_Hemoglobin" --> "LAB_UreaNitrogen"
27. "LAB_INR.PT." --> "LAB_PT"
28. "LAB_INR.PT." --> "LAB_PTT"
29. "LAB_Lactate" --> "LAB_AsparateAminotransferase.AST."
30. "LAB_Lactate" --> "LAB_CreatineKinase.CK."
31. "LAB_Lactate" --> "LAB_Glucose"
32. "LAB_Lactate" --> "LAB_INR.PT."
33. "LAB_Lactate" --> "LAB_Oxygen"
34. "LAB_Lactate" --> "mortality_in_hospital"
35. "LAB_Lymphocytes" <-> "LAB_Monocytes"
36. "LAB_Lymphocytes" <-> "LAB_Neutrophils"
37. "LAB_Lymphocytes" <-> "mortality_in_hospital"
38. "LAB_MCH" --> "LAB_Hemoglobin"
39. "LAB_MCHC" --> "LAB_CreatineKinase.CK."
40. "LAB_MCHC" --> "LAB_MCH"
41. "LAB_MCV" o-> "LAB_MCH"
42. "LAB_MCV" o-> "LAB_Potassium"
43. "LAB_MCV" o-o "LAB_pO2"
44. "LAB_Magnesium" --> "LAB_PT"
45. "LAB_Neutrophils" --> "LAB_Bicarbonate"
46. "LAB_Neutrophils" --> "LAB_Monocytes"
47. "LAB_Neutrophils" <-> "LAB_PlateletCount"
48. "LAB_Neutrophils" <-> "LAB_WhiteBloodCells"
49. "LAB_Oxygen" --> "mortality_in_hospital"
50. "LAB_PT" --> "LAB_PTT"
51. "LAB_Phosphate" --> "LAB_AsparateAminotransferase.AST."
52. "LAB_Phosphate" --> "LAB_Creatinine"
53. "LAB_Phosphate" --> "LAB_UreaNitrogen"
54. "LAB_PlateletCount" <-> "LAB_Lactate"
55. "LAB_PlateletCount" --> "LAB_MCHC"
56. "LAB_PlateletCount" --> "LAB_RDW"
57. "LAB_PlateletCount" <-> "mortality_in_hospital"
58. "LAB_Potassium" --> "LAB_AnionGap"
59. "LAB_Potassium" <-> "LAB_MCHC"
60. "LAB_Potassium" <-> "LAB_Magnesium"
61. "LAB_Potassium" --> "LAB_Phosphate"
62. "LAB_RDW" --> "LAB_AlkalinePhosphatase"
63. "LAB_RDW" --> "LAB_Bilirubin.Total"
64. "LAB_RDW" --> "LAB_MCHC"
65. "LAB_RDW" --> "LAB_PT"
66. "LAB_RDW" --> "LAB_Temperature"
67. "LAB_RedBloodCells" o-o "LAB_Hematocrit"
68. "LAB_Sodium" --> "LAB_Chloride"
69. "LAB_Sodium" --> "LAB_Magnesium"
70. "LAB_Sodium" --> "LAB_Oxygen"
71. "LAB_Sodium" --> "LAB_PTT"
72. "LAB_UreaNitrogen" --> "LAB_Glucose"
73. "LAB_UreaNitrogen" <-> "LAB_Magnesium"
74. "LAB_UreaNitrogen" <-> "LAB_PlateletCount"
75. "LAB_UreaNitrogen" --> "LAB_Temperature"
76. "LAB_UreaNitrogen" <-> "mortality_in_hospital"
77. "LAB_WhiteBloodCells" --> "LAB_AnionGap"
78. "LAB_WhiteBloodCells" o-> "LAB_PlateletCount"
79. "LAB_WhiteBloodCells" <-> "mortality_in_hospital"
80. "LAB_pH" o-> "LAB_BaseExcess"
81. "LAB_pH" o-o "LAB_CalculatedTotalCO2"
82. "LAB_pH" o-> "LAB_MCHC"
83. "LAB_pH" o-> "LAB_pCO2"
84. "LAB_pO2" o-> "LAB_BaseExcess"
85. "LAB_pO2" o-> "LAB_RDW"
86. "mortality_in_hospital" --> "LAB_Glucose"
87. "mortality_in_hospital" --> "LAB_INR.PT."
----
# Interpretation of Results 
A --> B

present

A is a cause of B. It may be a direct or indirect cause that may include other measured variables. Also, there may be an unmeasured confounder of A and B.

absent

B is not a cause of A.

A <-> B

present

There is an unmeasured variable (call it L) that is a cause of A and B. There may be measured variables along the causal pathway from L to A or from L to B.

absent

A is not a cause of B. B is not a cause of A.

 A o-> B
 
present

 Either A is a cause of B, or there is an unmeasured variable that is a cause of A and B, or both.
 
 absent



----
# Reproducibility and Future Directions 

This pipeline has the potential to be developed for the use of biological data (e.g. exploring causal relationships in a dataset with SNPs and gene expression). Furthermore, the use of principal component analysis may provide more efficiency to a large data set without as much user input. 



