library(dplyr)
library(yaml)
library(tidyr)

project_dir <- '/../mnt/project/'

getTable <- function(table_name, n=-1L) {
   tibble(read.csv(file = paste0(project_dir, 'MIMIC/', table_name, '.csv'), header=TRUE, sep=',', nrow=n))
}

# Read input files
user_input <- read_yaml(paste0(project_dir, 'ip.txt'))
admissions <- getTable('ADMISSIONS')
patients <- getTable('PATIENTS')
icustays <- getTable('ICUSTAYS')


# filter down to requested cohort based on diagnosis
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

# TODO: filter down other tables to subject_id's in this cohort
# admissions, patients, icustays



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



#### ENCODE OUTCOMES ####

# metric1: mortality rate
admissions <- admissions %>%
   mutate(mortality_in_hospital = as.numeric(hospital_expire_flag))

mortality_data <- admissions %>% 
   select(subject_id, hadm_id, mortality_in_hospital)

# metric2: readmission rate
admissions <- admissions %>%
   mutate(
      admittime = as.POSIXct(admittime, format="%Y-%m-%d %H:%M:%S"),
      dischtime = as.POSIXct(dischtime, format="%Y-%m-%d %H:%M:%S")
   )

readmission_data <- admissions %>%
   arrange(subject_id, admittime) %>%  # Sort by patient and admission time
   group_by(subject_id) %>%
   mutate(
      next_admit = lead(admittime),  # Next admission time
      readmission = ifelse(!is.na(next_admit) & next_admit - dischtime <= 30, 1, 0)  # Readmission within 30 days
   ) %>%
   select(subject_id, hadm_id, readmission) %>%
   ungroup()

# metric3: length of stay (los)
los_data <- admissions %>%
   mutate(
      los_days = as.numeric(difftime(dischtime, admittime, units = "days"))  # Compute LOS in days
   ) %>%
   select(subject_id, hadm_id, los_days)

# metric4: icu transfers
icu_transfers <- icustays %>%
   group_by(subject_id, hadm_id) %>%
   summarise(icu_transfers = n() - 1)  # Transfers occur when a patient moves to another ICU

# merged metrics
outcomes <- mortality_data %>%
   left_join(readmission_data, by = c("subject_id", "hadm_id")) %>%
   left_join(los_data, by = c("subject_id", "hadm_id")) %>%
   left_join(icu_transfers, by = c("subject_id", "hadm_id"))

cohort <- cohort %>%
   left_join(outcomes, by = c("subject_id", "hadm_id"))

# write modified/transformed dataframe to job directory
write.csv(cohort, file = "parsed_input.csv", row.names = FALSE)

# move that from job directory back to project directory
system('dx upload parsed_input.csv --wait')
