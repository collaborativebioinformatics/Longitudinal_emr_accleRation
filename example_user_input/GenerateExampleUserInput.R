
library(yaml)

writeLines(as.yaml(list('filterTables' = list('Diagnosis' = list('long_title' = 'Pneumonia')),
                        'select' = list('Labs'),
                        'outcome' = list('Mortality'))),
           '~/Desktop/Longitudinal_emr_accleRation/example_user_input/user_input_yaml.txt')