# Functions to read a Fish-AIR CSV applying column names based on term IRI

require(XML)

get_term_to_col_idx <- function(meta_xml_path, file_location, archive_child_names = c("core", "extension")) {
  # Returns a list of term URI -> R column indexes
  
  # Parse meta.xml file creating a list of fields for the file_location(aka filename)
  data <- XML::xmlParse(meta_xml_path, asTree=TRUE)
  xml_data <- XML::xmlToList(data)
  items <- xml_data[names(xml_data) %in% archive_child_names]
  file_columns <- items[lapply(items, function(x) x$files$location) == file_location]
  target_file_columns <- file_columns[[1]]
  
  # Filter out fields that do not have both "index" and "term"
  has_index_and_term_names <- function(field) {
    "index" %in% names(field) & "term" %in% names(field)
  }
  valid_file_columns <- target_file_columns[unlist(lapply(target_file_columns, has_index_and_term_names))]
  
  # Create a list from term URI -> column index
  # increment since R indexing starts at 1 so
  indexes <- vapply(valid_file_columns, function(x) as.numeric(x["index"])+1, numeric(1)) 
  names(indexes) <- vapply(valid_file_columns, function(x) x["term"], character(1))
  indexes
}

fa_read_csv <- function(csv_path, meta_xml_path, term_to_colname) {
  # Read Fish-AIR CSV file
  df <- read.csv(file = csv_path)
  
  # Create a list from term URI -> R column indexes
  term_to_col_idx <- get_term_to_col_idx(meta_xml_path, basename(csv_path))
  
  # Filter to the columns requested in term_to_colname
  col_idx_list = unlist(lapply(names(term_to_colname), function(term) {term_to_col_idx[term]}), use.names = FALSE)
  df_filtered <- df[, col_idx_list]
  
  # Change column names to match those in term_to_colname
  new_names = unlist(lapply(names(term_to_colname), function(term) {term_to_colname[term]}), use.names = FALSE)
  names(df_filtered) <- new_names

  df_filtered
}
