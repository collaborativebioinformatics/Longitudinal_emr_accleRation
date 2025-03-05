# Required steps: change path on lines 8 and 48



library(igraph)

# Specify the directory where you want to save your figures
#save_directory <- "/path/to/save/graphs"
#save_directory <- "/Users/bizecca/Documents/a_CooperLab/project_CMU_Hackathon/"


# Function to extract edges from all txt files in a directory
process_file <- function(file_path) {
  
  # Read file lines
  tetrad_data <- readLines(file_path)
  
  # Extract nodes from the "Graph Nodes" section
  nodes_line <- grep("Graph Nodes:", tetrad_data, value = TRUE)
  nodes <- unlist(strsplit(sub("Graph Nodes:", "", nodes_line), ";"))
  nodes <- trimws(nodes)
  
  # Extract edges from the "Graph Edges" section
  edges_start <- grep("Graph Edges:", tetrad_data)
  edges_data <- tetrad_data[(edges_start + 1):length(tetrad_data)]
  
  # Parse edges into a data frame
  edges <- do.call(rbind, lapply(edges_data, function(line) {
    matches <- regmatches(line, regexec("(.+) (---|-->|<--) (.+)", line))[[1]]
    if (length(matches) == 4) {
      c(trimws(matches[2]), trimws(matches[4]), trimws(matches[3]))
    } else {
      NULL
    }
  }))
  
  # Create a data frame of edges
  edges_df <- data.frame(from = edges[, 1], to = edges[, 2], type = edges[, 3], stringsAsFactors = FALSE)
  
  # Add filename to edges_df
  edges_df$filename <- basename(file_path)
  
  # Return a list with nodes and edges
  return(list(nodes = nodes, edges = edges_df))
}

# Get the list of .txt files (Tetrad output files) in the directory (replace "your_directory" with the actual directory)
#file_paths <- list.files(path = "your_directory", pattern = "\\.txt$", full.names = TRUE)
#file_paths <- list.files(path = "/Users/bizecca/Documents/a_CooperLab/project_CMU_Hackathon/", pattern = "\\.txt$", full.names = TRUE)


# Process each file and store edges for all files
results <- lapply(file_paths, process_file)


# Find files that do/don't have bootstraps
# Loop through each file's result and check for numbers in edges
files_with_bootstraps = NULL
files_without_bootstraps = NULL

for (i in seq_along(results)) {
  edges_df <- results[[i]]$edges
  
  # Check if any edge has a colon in the 'type' column (which represents the bootstrap values)
  has_colon <- grepl(":", edges_df$to)  # This checks for the presence of a colon
  
  # If any edge has a colon (meaning it has a bootstrap value), add the file to 'files_with_bootstraps'
  if (any(has_colon)) {
    files_with_bootstraps <- c(files_with_bootstraps, basename(file_paths[i]))
  } else {
    files_without_bootstraps <- c(files_without_bootstraps, basename(file_paths[i]))
  }
}


# # # Obtain edges for each file
# Subset results dataframe for files_with_bootstraps and files_without_bootstraps
results_with_bootstraps <- lapply(files_with_bootstraps, function(file_name) {
  # Find the corresponding result for this filename
  matching_result <- results[sapply(results, function(result) any(result$edges$filename == file_name))]
  return(matching_result)
})


# Subset results for files without bootstraps (filenames without bootstrap values)
results_without_bootstraps <- lapply(files_without_bootstraps, function(file_name) {
  # Find the corresponding result for this filename
  matching_result <- results[sapply(results, function(result) any(result$edges$filename == file_name))]
  return(matching_result)
})

# # # Make figures for results_without_bootstraps
# Loop over each subset in 'results_without_bootstraps'
for (file_result in results_without_bootstraps) {
  
  # Extract the edges data frame from the current file's result
  edges_df <- file_result[[1]]$edges  # Assuming the first element contains 'edges'
  
  # Create the graph from the edges data frame
  graph <- graph_from_data_frame(edges_df, directed = TRUE)
  
  # Add edge names to plot
  edge_labels <- edges_df$type
  
  # Define output PDF filename
  output_pdf <- paste0("graph_", basename(file_result[[1]]$edges$filename[1]), ".pdf")
  
  # Open a PDF device to save the plot
  pdf(output_pdf)

  # Plot the graph with improved visualization
  plot(graph,
       layout = layout_with_kk,  # Use Fruchterman-Reingold layout for better visualization
       vertex.color = "skyblue",  # Set vertex color
       vertex.frame.color = "white",  # Set frame color for vertices
       vertex.label.color = "darkblue",  # Set label color for vertices
       vertex.label.cex = 0.8,  # Set label size
       edge.arrow.size = 0.7,  # Set arrow size for directed edges
       edge.curved = 0.2,  # Set edge curvature
       edge.color = "darkgray",  # Set edge color
       edge.label = edge_labels,  # Add edge labels from the 'type' column
       edge.label.cex = 0.8,  # Set edge label size
       edge.label.color = "black",  # Set edge label color
       main = paste("Causal Discovery: ", file_result[[1]]$edges$filename[1]),  # Set title with filename
       )
  dev.off()
}


# Make figures for results_with_bootstraps
# Extract bootstrap value (to print these on the graphs)
bootstrap_value <- sub(".*:(\\d+\\.\\d+).*", "\\1", results_with_bootstraps)
bootstrap_value = bootstrap_value[1] # save only the first value instead of a repeating string
bootstrap_value <- as.numeric(bootstrap_value)  


# Loop over each subset in 'results_without_bootstraps'
for (file_result in results_with_bootstraps) {
  
  # Extract the edges data frame from the current file's result
  edges_df <- file_result[[1]]$edges  # Assuming the first element contains 'edges'

  # Remove all text after '[' in the 'from' column to make graph labels look nice
  edges_df$from <- sub("\\-.*", "", edges_df$from)
  
  # Remove all text after ']' in the 'to' column to make graph labels look nice
  edges_df$to <- sub("\\].*", "", edges_df$to)
  
  # Create the graph from the edges data frame
  graph <- graph_from_data_frame(edges_df, directed = TRUE)
  
  # Add edge names to plot
  edge_labels <- edges_df$type
  
  # Define output PDF filename
  output_pdf <- paste0("graph_", basename(file_result[[1]]$edges$filename[1]), ".pdf")
  
  # Open a PDF device to save the plot
  pdf(output_pdf)
  
  # Plot the graph with improved visualization
  plot(graph,
       layout = layout_with_kk,  # Use Kamada-Kawai layout for better label positioning
       vertex.color = "skyblue",  # Set vertex color
       vertex.frame.color = "white",  # Set frame color for vertices
       vertex.label.color = "darkblue",  # Set label color for vertices
       vertex.label.cex = 0.8,  # Set label size
       edge.arrow.size = 0.7,  # Set arrow size for directed edges
       edge.curved = 0.2,  # Set edge curvature
       edge.color = "darkgray",  # Set edge color
       edge.label = edge_labels,  # Add edge labels from the 'type' column
       edge.label.cex = 0.8,  # Set edge label size
       edge.label.color = "black",  # Set edge label color
       main = paste("Causal Discovery: ", file_result[[1]]$edges$filename[1], 
                    " | Bootstrap Value: ", bootstrap_value)   )
  dev.off()
}


