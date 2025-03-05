# Load necessary libraries
library(yaml)

# Read the YAML file
yaml_file <- "user_input_yaml.txt"
yaml_data <- yaml.load_file(yaml_file)

# Extract options from the YAML file
algorithm <- yaml_data$tetrad_args$algorithm
alpha <- yaml_data$tetrad_args$alpha
score <- yaml_data$tetrad_args$score
data_type <- yaml_data$tetrad_args$datatype  # Assuming 'datatype' is included in the YAML
dataset <- yaml_data$tetrad_args$dataset
knowledge <- yaml_data$tetrad_args$knowledge
test <- yaml_data$tetrad_args$test
numberResampling <- yaml_data$tetrad_args$numberResampling
delimiter <- yaml_data$tetrad_args$delimiter

# Construct the tetrad_command
tetrad_command <- paste0("java -jar ./causal-cmd-1.12.0-jar-with-dependencies.jar",
                         " --algorithm ", algorithm,
                         " --data-type ", data_type,
                         " --dataset ", dataset,
                         " --delimiter ", delimiter,
                         # " --metadata ", paste0(getwd(), "/metadata_v01.txt"),
                         " --knowledge ", knowledge),
                         " --test ", test,
                         " --alpha ", alpha,
                         " --score ", score,
                         " --numberResampling ", numberResampling)

# Add --knowledge argument only if a knowledge file is specified
if (!is.null(knowledge) && nchar(knowledge) > 0) {
  tetrad_command <- paste0(tetrad_command, " --knowledge ", knowledge)
}

# Print the command for debugging purposes
print(tetrad_command)

# Execute the command
system(command = tetrad_command)
