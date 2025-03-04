library(yaml)
setwd('~/Desktop/MIMIC/mimic-iii-clinical-database-carevue-subset-1.4/')
user_input <- read_yaml(file = '~/Desktop/MIMIC/user_input_yaml.txt')

getTable <- function(table_name, n=-1L) {
   tibble(read.csv(file = paste0('~/Desktop/MIMIC/mimic-iii-clinical-database-carevue-subset-1.4/', table_name, '.csv'), header=TRUE, sep=',', nrow=n))
}


# start with filtering:
# we will provide functionality for filtering via:
#     - Diagnoses based on icd9_code
#     - Diagnoses based on diagnosis name

if ('Diagnosis' %in% names(user_input$filterTables)) {
   # use diagnoses to get a list of subject_id and hadm_id that correspond to the requested diagnosis code
   # this data is in DIAGNOSES_ICD.csv
   
   # get all diagnosis subject_id, hadm_id, and icd9_code
   dx <- getTable('DIAGNOSES_ICD')
   
   # get the user input data to define the diagnosis filtering criteria
   dx_filter_data <- user_input$filterTables$Diagnosis
   if ('icd9_code' %in% names(dx_filter_data)) { # user provided a specific diagnosis code = our lives are easy
      filter_rows <- which(dx$icd9_code == dx_filter_data$icd9_code)
      
   } else if ('long_title' %in% names(dx_filter_data)) {
      # get diagnosis names to code dictionary
      dx_names <- getTable('D_ICD_DIAGNOSES')
      # join with dx to get human readable names
      dx <- left_join(
         x = dx,
         y = dx_names[c('icd9_code', 'long_title')],
         by = join_by(icd9_code)
      )
      filter_rows <- grep(dx_filter_data$long_title, dx$long_title, ignore.case=TRUE)
   }
   
   # filter down to the requested rows
   cohort <- dx[filter_rows, c('subject_id', 'hadm_id')]
}


# now select:
#     - labs

if (any(user_input$select == 'Labs')) {
   labs <- getTable('LABEVENTS', n=50000)
   lab_names <- getTable('D_LABITEMS', n=50000)
   
   # join lab values with current cohort
   labs <- inner_join(
      x = cohort,
      y = labs %>% select(subject_id, hadm_id, itemid, valuenum),
      relationship = 'many-to-many',
      by = join_by(subject_id, hadm_id)
   )
   
   # convert itemid to human readable lab names
   labs <- left_join(
      x = labs, 
      y = lab_names %>% select(itemid, label), 
      by = join_by(itemid)
   ) %>%
      mutate(label = paste0('LAB_', gsub(' ', '', label)))
   
   # aggregate each lab per visit (hadm_id)
   labs <- labs %>% 
      summarise(
         value = mean(valuenum), 
         .by = c(subject_id, hadm_id, label)
      )
   
   # pivot to wide format
   labs <- labs %>%
      tidyr::pivot_wider(
         id_cols = c(subject_id, hadm_id),
         values_from = value,
         names_from = label
      )
   
   cohort <- labs
}


# TODO (Rishika): implement encoding outcomes (mortality, readmission, length of stay, etc.)
# this data is in a bunch of different tables



