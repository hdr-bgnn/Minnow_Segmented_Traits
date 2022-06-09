df <- read.csv("../minnow.filtered.from.imagequalitymetadata_7Jun2022.csv", header = TRUE)

source("../OSC/chunkData.R")

starts <- c(1, 1001, 2001, 3001, 4001, 5001, 6001)
ends <- c(1000, 2000, 3000, 4000, 5000, 6000, nrow(df))
#one day I'll be clever enough not to do this.

for(i in 1:length(starts)){
  chunkData(df = df, start = starts[i], end = ends[i])
}

#check that it worked

#from full dataset
og_names <- df$original_file_name
length(og_names)

#get original file names from all other datasets and combine
files <- list.files(pattern = '*.csv')
combo <- lapply(files, read.csv) %>% bind_rows()
combo_names <- combo$original_file_name

#check for diffs between names
setdiff(og_names, combo_names)
setdiff(combo_names, og_names)
#no difference!
