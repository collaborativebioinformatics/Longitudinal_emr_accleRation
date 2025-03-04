
library(yaml)

writeLines(as.yaml(list('filterTables' = list('Diagnosis' = list('long_title' = 'Pneumonia')),
                        'select' = list('Labs'),
                        'outcome' = list('Mortality'),
                        'tetrad_args' = list('algorithm' = 'grasp-fci',
                                             'alpha' = 0.01))),
           '~/Desktop/Longitudinal_emr_accleRation/example_user_input/user_input_yaml.txt')