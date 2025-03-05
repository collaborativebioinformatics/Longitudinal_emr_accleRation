# Load necessary libraries
library(yaml)

# Accept the YAML file as a command-line argument
args <- commandArgs(trailingOnly = TRUE)
yaml_file <- args[1]  # Get the input YAML file

# Read the YAML file
yaml_data <- yaml.load_file(yaml_file)

# Extract options from the YAML file
algorithm <- yaml_data$tetrad_args$algorithm
alpha <- yaml_data$tetrad_args$alpha
score <- yaml_data$tetrad_args$score
data_type <- yaml_data$tetrad_args$datatype  # Assuming 'datatype' is included in the YAML
knowledge <- yaml_data$tetrad_args$knowledge
test <- yaml_data$tetrad_args$test
numberResampling <- yaml_data$tetrad_args$numberResampling
delimiter <- yaml_data$tetrad_args$delimiter
prefix <- yaml_data$tetrad_args$prefix

# Get the list of CSV files in the directory (the directory where ParseUserInput.R placed them)
csv_files <- list.files(pattern = "*.csv")

# Loop over the CSV files
for (dataset in csv_files) {
  # Load the dataset
  dataset_df <- read.csv(dataset, header = TRUE, sep = ',')

  # Remove columns with more than 30% NA values
  na_threshold <- 0.30
  dataset_df <- dataset_df[, colSums(is.na(dataset_df)) / nrow(dataset_df) <= na_threshold]

  # Impute remaining NA values with column means
  dataset_df[] <- lapply(dataset_df, function(x) {
    if (is.numeric(x)) {
      # Impute with column mean
      x[is.na(x)] <- mean(x, na.rm = TRUE)
    }
    return(x)
  })

  # Save the cleaned dataset
  cleaned_dataset <- paste0("cleaned_", dataset)
  write.csv(dataset_df, cleaned_dataset, row.names = FALSE)

  # Construct the tetrad_command
  tetrad_command <- paste0("java -jar ./causal-cmd-1.12.0-jar-with-dependencies.jar",
                           " --algorithm ", algorithm,
                           " --data-type ", data_type,
                           " --dataset ", cleaned_dataset,
                           " --delimiter ", delimiter,
                           " --test ", test,
                           " --alpha ", alpha,
                           " --score ", score,
                           " --numberResampling ", numberResampling,
                           " --prefix ", prefix)

  # Print the command for debugging purposes
  print(tetrad_command)

  # Execute the command
  system(command = tetrad_command)
}
