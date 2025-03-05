
library(yaml)

writeLines(as.yaml(list('filterTables' = list('Diagnosis' = list('long_title' = 'Pneumonia')),
                        'select' = list('Labs'),
                        'outcome' = list('Mortality'),
                        'tetrad_args' = list('algorithm' = 'grasp-fci','alpha' = 0.01,'datatype' = 'continuous', 'dataset'='temp.csv', 'prefix'='example_output_name','numberResampling'= 0,'delimiter' = 'comma','score' = 'cg-bic-score','test' = 'cg-lr-test'))),
           'user_input_yaml.txt')


#NOTE CHANGE THIS LAST LINE BACK TO BEFORE RE-UPLOAD 
#'~/Desktop/Longitudinal_emr_accleRation/example_user_input/user_input_yaml.txt')


#Tetrad Argument Options: 
#dataType Options 
#Data type Options: all, continuous, covariance, discrete, mixed
#Algorithm Options: boss, boss-lingam, bpc, ccd, cfci, cpc, cstar, dagma, direct-lingam, fas, fask, fask-pw, fci, fci-iod, fci-max, fges, fges-mb, fofc, ftfc, gfci, grasp, grasp-fci, ica-ling-d, ica-lingam, images, images-boss, mgm, pag-sampling-rfci, pc, pc-mb, r-skew, r3, rfci, skew, spfci, svar-fci, svar-gfci
#Delimiter Options: colon, comma, pipe, semicolon, space, tab, whitespace
#Score Options: bdeu-score, cg-bic-score, dg-bic-score, disc-bic-score, ebic-score, gic-scores, m-sep-score, poisson-prior-score, sem-bic-score, zsbound-score
#Test Options: cci-test, cg-lr-test, chi-square-test, dg-lr-test, fisher-z-test, g-square-test, kci-test, m-sep-test, mag-sem-bic-test, prob-test, sem-bic-test

#if discrete variables being used can add other arugments:
#    --dataType <string>     "continuous" or "discrete"
#    --numCategories <integer>   Number of categories for discrete variables (min = 2)

#a full list of tetrad commands can be visualized by --help-all in tetrad command line 



###NOTE TO ADD KNOWLEDGE PARAMETERS 
#USER Must create knowledge.txt file to enter background knowledge. 
#For example, information about the time order of the measured variables
#please see knowledge.txt in example_usr_input for reference 

#more information regarding this: 
#https://www.phil.cmu.edu/projects/tetrad/old/tet3/chp4.htm
#https://bd2kccd.github.io/docs/causal-cmd/
