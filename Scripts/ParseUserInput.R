install.packages(c('DBI', 'RSQLite'))

library(dplyr)
library(yaml)
library(tidyr)
library(RSQLite)
library(DBI)

system('dx download mimic3.sqlite')

conn001 <- dbConnect(SQLite(), 'mimic3.sqlite')

# create list structure to which we will add features & outcome dataframes separately
features_list <- list()
outcomes_list <- list()

# Read user input data
project_dir <- '/../mnt/project/'

# Change the input file name 
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
   
   return(dbGetQuery(conn001, query))
}

# filter down to requested cohort based on diagnosis
if ('Diagnosis' %in% names(user_input$filterTables)) {
   # use diagnoses to get a list of subject_id and hadm_id that correspond to the requested diagnosis code
   
   # get the user input data to define the diagnosis filtering criteria
   dx_filter_data <- user_input$filterTables$Diagnosis
   if ('icd9_code' %in% names(dx_filter_data)) { # user provided a specific diagnosis code = our lives are easy
      query <- paste0(
         "SELECT subject_id, hadm_id
         FROM DIAGNOSES_ICD
         WHERE icd9_code = '", dx_filter_data$icd9_code, "'"
      )
      
   } else if ('long_title' %in% names(dx_filter_data)) {
      query <- paste0(
         "SELECT subject_id, hadm_id
         FROM DIAGNOSES_ICD
         INNER JOIN D_ICD_DIAGNOSES ON D_ICD_DIAGNOSES.icd9_code = DIAGNOSES_ICD.icd9_code
         WHERE D_ICD_DIAGNOSES.long_title like '%", dx_filter_data$long_title, "%'"
      )
   }
   
   # use generated query to get necessary data
   cohort <- dbGetQuery(conn001, query)
}

# LAB VALUES
if ('Labs' %in% user_input$select) {
   # only take 50 most commonly measured lab tests
   labevent_count <- paste0('SELECT itemid, COUNT(*) FROM LABEVENTS GROUP BY itemid ORDER BY COUNT(*) DESC LIMIT 50')
   labevent_count <- dbGetQuery(conn001, labevent_count)
   top50labs <- labevent_count$itemid
   
   # grab lab values from lab events table, joining with d_labitems to get human readable names
   # only query for the subject_id and hadm_id in our current cohort
   labs <- paste0(
      'SELECT subject_id, hadm_id, valuenum, D_LABITEMS.label 
      FROM LABEVENTS LEFT JOIN D_LABITEMS ON LABEVENTS.itemid = D_LABITEMS.itemid
      WHERE subject_id IN (', paste(cohort$subject_id, collapse = ', '), ') 
         AND hadm_id IN (', paste(cohort$hadm_id, collapse = ', '), ')
         AND LABEVENTS.itemid IN (', paste(top50labs, collapse = ', '), ')')
   labs <- dbGetQuery(conn001, labs)
   
   # join lab values with current cohort
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
   
   # TODO: rename this dataframe something useful? write.csv to directory for input to tetrad?
   features_list[['Labs']] <- labs
}

# TODO: fix this!
if ('Diagnoses' %in% user_input$select) {
   top50icd <- dbGetQuery(conn001, 'SELECT icd9_code, COUNT(*) FROM DIAGNOSES_ICD GROUP BY icd9_code ORDER BY COUNT(*) DESC LIMIT 50')
   top50icd <- top50icd$icd9_cod
   
   query <- paste0("
    SELECT subject_id, hadm_id, icd9_code
    FROM DIAGNOSES_ICD
    WHERE subject_id IN (", paste(cohort$subject_id[1:10], collapse = ', '), ") 
         AND hadm_id IN (", paste(cohort$hadm_id[1:10], collapse = ', '), ")
         AND icd9_code IN (", paste(top50icd, collapse = ', '), ")
   ")
   diagnoses_data <- dbGetQuery(conn001, query)
   
   
   
   features_list[['Diagnoses']] <- diagnoses_data
}


if ('Micro_data' %in% user_input$select) {
   # TODO: this!
   micro_data = data.frame()
   
   features_list[['Micro_data']] <- micro_data
}

if (any(user_input$outcome %in% c('Mortality', 'Readmission', 'Length_of_stay'))) {
   admissions_query <- paste0("
      SELECT *
      FROM ADMISSIONS
      WHERE subject_id IN (", paste(cohort$subject_id, collapse = ', '), ") 
            AND hadm_id IN (", paste(cohort$hadm_id, collapse = ', '), ")
   ")
   admissions_data <- dbGetQuery(conn001, admissions_query)
}


if (any(user_input$outcome == 'Mortality')) {
   mortality_data <- admissions_data %>%
      mutate(mortality_in_hospital = as.numeric(hospital_expire_flag)) %>% 
      select(subject_id, hadm_id, mortality_in_hospital)
   
   outcomes_list[['Mortality']] <- mortality_data %>% arrange(subject_id, hadm_id)
}

# TODO: user should specify readmission within X days
if ('Readmission' %in% user_input$outcome) {
   readmission_data <- admissions_data %>%
      mutate(
         admittime = as.POSIXct(admittime, format="%Y-%m-%d %H:%M:%S"),
         dischtime = as.POSIXct(dischtime, format="%Y-%m-%d %H:%M:%S")
      ) %>%
      arrange(subject_id, admittime) %>%  # Sort by patient and admission time
      group_by(subject_id) %>%
      mutate(
         next_admit = lead(admittime),  # Next admission time
         readmission = ifelse(!is.na(next_admit) & next_admit - dischtime <= 30, 1, 0)  # Readmission within 30 days
      ) %>%
      select(subject_id, hadm_id, readmission) %>%
      ungroup()
   
   # TODO: add this to any and all requested feature sets (e.g., labs)
   outcomes_list[['Readmission']] <- readmission_data %>% arrange(subject_id, hadm_id)
}


if ('Length_of_stay' %in% user_input$outcome) {
   los_data <- admissions_data %>%
      mutate(
         los_days = as.numeric(difftime(dischtime, admittime, units = "days"))  # Compute LOS in days
      ) %>%
      select(subject_id, hadm_id, los_days)
   
   outcomes_list[['Length_of_stay']] <- los_data %>% arrange(subject_id, hadm_id)
}


if ('icu_transfers' %in% user_input$outcome) {
   # TODO: check to make sure count - 1 works
   icu_stays_query <- paste0("
      SELECT subject_id, hadm_id, COUNT(icu_transfers) - 1
      FROM ICUSTAYS
      WHERE subject_id IN (", paste(cohort$subject_id, collapse = ', '), ") 
            AND hadm_id IN (", paste(cohort$hadm_id, collapse = ', '), ")
      GROUP BY subject_id, hadm_id
   ")
   icu_transfers_data <- dbGetQuery(conn001, icu_stays_query)
   
   outcomes_list[['icu_transfers']] <- icu_transfers_data %>% arrange(subject_id, hadm_id)
}

# COMBINE OUTCOMES into one data.frame, if there is more than one outcome and the user requested combining them
if (length(outcomes_list) == 1L) { # single outcome dataframe, keep it in list structure
   num_outcomes <- 1L
   
} else if (length(outcomes_list) > 1L) { # multiple outcomes, check if want to combines
   
   # if they want to combine, check if possible, then combine
   if (user_input$combine_outcomes) {
      if (length(unique(sapply(outcomes_list, nrow))) != 1L) {
         stop('Outcome dataframes do not have same number of rows!')
      }
      
      outcomes_data <- outcomes_list[[1]]
      for (i in seq_along(outcomes_list)[-1]) {
         outcomes_data <- inner_join(
            x = outcomes_data,
            y = outcomes_list[[i]],
            by = join_by(subject_id, hadm_id)
         )
      }
      outcomes_list <- list(outcomes_data) # put back into list format, so consistent with other cases
      
   }
   
   # whether combined or not, get the number of separate outcomes for later
   num_outcomes <- length(outcomes_list)
}

### COMBINE FEATURE SETS AND OUTCOME(S) DATA, depending on user input
# WRITE DATASETS TO CSV FOR INPUT TO TETRAD
num_feat_sets <- length(features_list)
num_outcomes <- length(outcomes_list)

combine_outcome_feature_writecsv <- function(featDF, outDF, filename) {
   data <- inner_join(
      x = featDF,
      y = outDF,
      by = join_by(subject_id, hadm_id)
   ) %>%
      select(-subject_id, -hadm_id)
   
   write.csv(data, 
             file = paste0(filename, '.csv'), 
             # quote = FALSE,
             row.names = FALSE)
}

# TODO: change the filenames to something meaningful
if (num_feat_sets == 1L && num_outcomes == 1L) {
   combine_outcome_feature_writecsv(features_list[[1]], outcomes_list[[1]], 'step1_parsed_output')
   
} else if (num_feat_sets > 1L && num_outcomes == 1L) {
   for (i in seq_along(features_list)) {
      combine_outcome_feature_writecsv(features_list[[i]], outcomes_list[[1]], paste0('step1_parsed_output_',i))
   }
   
} else if (num_feat_sets == 1L && num_outcomes > 1L) {
   for (i in seq_along(outcomes_data)) {
      combine_outcome_feature_writecsv(features_list[[1]], outcomes_list[[i]], paste0('step1_parsed_output_',i))
   }
   
} else if (num_feat_sets > 1L && num_outcomes > 1L) {
   for (i in seq_along(features_list)) {
      for (j in seq_along(outcomes_data)) {
         combine_outcome_feature_writecsv(features_list[[i]], outcomes_list[[j]], paste0('step1_parsed_output_',i,'_',j))
      }
   }
}

system('dx upload temp.csv --wait')

dbDisconnect(conn001)
