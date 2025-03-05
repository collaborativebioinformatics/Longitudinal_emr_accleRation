library(dplyr)
library(yaml)
library(tidyr)
library(RSQLite)
library(DBI)

project_dir <- '/../mnt/project/'

# pull down SQLite database
system('dx download mimic3.sqlite')
conn001 <- dbConnect(SQLite(), 'mimic3.sqlite')

# Read input files
user_input <- read_yaml(paste0(project_dir, 'ip.txt'))


getTableQuery <- function(table_name, columns, join_type='', join_table='', join_column='', filter_type='=', filter_column='', filter_value='', n=...) {
   query <- paste0('SELECT ', columns, ' FROM ', table_name)
   if (join_type != '' ) {
      query <- paste0(query, ' ', join_type ,' JOIN ', join_table, ' ON ', join_column)
   } 

   if (filter_type != '') {
      if (filter_type == 'IN') {
         query <- paste0(query, ' WHERE ', filter_column, ' IN (', filter_value, ')')
      } else if (filter_type == 'LIKE') {
         query <- paste0(query, ' WHERE ', filter_column, " LIKE '%", filter_value, "%'")
      } else {
         query <- paste0(query, ' WHERE ', filter_column, ' = ', filter_value)
      }
   }

   if(n != 0) {
      query <- paste0(query, ' LIMIT ', n)
   }
   
   return dbGetQuery(conn001, query)
}


admissions <- getTableQuery(table_name='ADMISSIONS','subject_id, hadm_id, admittime, dischtime, hospital_expire_flag')
patients <- getTableQuery(table_name='PATIENTS','subject_id')
icustays <- getTableQuery(table_name='ICUSTAYS','subject_id, hadm_id')


# filter down to requested cohort based on diagnosis
if ('Diagnosis' %in% names(user_input$filterTables)) {
   # use diagnoses to get a list of subject_id and hadm_id that correspond to the requested diagnosis code
   
   # get the user input data to define the diagnosis filtering criteria
   dx_filter_data <- user_input$filterTables$Diagnosis
   if ('icd9_code' %in% names(dx_filter_data)) { # user provided a specific diagnosis code = our lives are easy
      query <- getTableQuery(table_name='DIAGNOSES_ICD', columns='subject_id, hadm_id', filter_column='icd9_code', filter_value=dx_filter_data$icd9_code)
      
   } else if ('long_title' %in% names(dx_filter_data)) {
      query <- getTableQuery(table_name='DIAGNOSES_ICD', columns='subject_id, hadm_id', join_type='LEFT', join_table='D_ICD_DIAGNOSES', join_column='icd9_code', filter_type='LIKE', filter_column='D_ICD_DIAGNOSES.long_title', filter_value=dx_filter_data$long_title)
   }
   
   # use generated query to get necessary data
   cohort <- dbGetQuery(conn001, query)
}

# TODO: filter down other tables to subject_id's in this cohort
# admissions, patients, icustays



if (any(user_input$select == 'Labs')) {
   labevent_count <- paste0('SELECT itemid, COUNT(*) FROM LABEVENTS GROUP BY itemid LIMIT 50')
   labevent_count <- dbGetQuery(conn001, labevent_count)
   top50labs <- labevent_count$itemid

   # join lab values with current cohort
   labs <- paste0(
      'SELECT subject_id, hadm_id, valuenum, D_LABITEMS.label 
      FROM LABEVENTS LEFT JOIN D_LABITEMS ON itemid
      WHERE subject_id IN (', paste(cohort$subject_id, collapse = ', '), ') 
         AND hadm_id IN (', paste(cohort$hadm_id, collapse = ', '), ')
         AND itemid IN (', paste(top50labs, collapse = ', '), ')')
   labs <- dbGetQuery(conn001, labs)

   labs <- inner_join(
      x = cohort,
      y = labs %>% select(subject_id, hadm_id, valuenum, label),
      relationship = 'many-to-many',
      by = join_by(subject_id, hadm_id)
   )
   
   # convert itemid to human readable lab names
   labs <- labs %>%
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
   
   labs
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

dbDisconnect(conn001)