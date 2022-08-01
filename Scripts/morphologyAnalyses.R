# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)
library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr)
library(RColorBrewer)
library(reshape2)

#get list of file names
#path is in the OSC 
setwd("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows/Morphology/Measure")
m.files <- list.files(pattern = '*.json')

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile, unexpected.escape = "keep")
  #some json files have null for scale (index 15 & 16)
  if(isTRUE(is.null(input[15][[1]][[1]]))){
    input[15][[1]][[1]] <- "none"
  }
  if(isTRUE(is.null(input[16][[1]][[1]]))){
    input[16][[1]][[1]] <- "none"
  }
  df <- as.data.frame(input)
  df$file.name <- gsub(jfile,
                       pattern = "_measure.json", #can change this depending on the file name
                       replacement = "")
  return(df)
}

measure.df <- lapply(m.files, json_df) %>% 
  dplyr::bind_rows()

#check have all the files
nrow(measure.df) #446
length(m.files) #446

str(measure.df)
View(measure.df)

#in files dir
write.csv(measure.df, "measure.df.burress.csv", row.names = FALSE)

#remove those that don't have a scale
errors <- measure.df[measure.df$X.none. == "none",] %>% drop_na(X.none.)
nrow(errors) #18 images

measure.df.scale <- measure.df[!(measure.df$base_name %in% errors$base_name),]

#need to combine metatdata about fish
setwd("/users/PAS2136/balkm/minnowTraits/Files/")
meta <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE)

#remove file extension
meta$original_file_name <- gsub(meta$original_file_name,
                                pattern = ".jpg",
                                replacement = "")

#merge
meta.measure.df.scale <- merge(meta, measure.df.scale, 
                               by.x = "original_file_name",
                               by.y = "base_name",
                               all.x = FALSE, all.y = TRUE)

write.csv(meta.measure.df.scale, "meta.merged.measure.burress.errors.removed.csv", 
          row.names = FALSE)

#load Burress to compare
b.df <- read.csv("Previous Fish Measurements - Burress et al. 2016.csv", header = TRUE)
