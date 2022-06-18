# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)
library(tidyr)
library(dplyr)
library(ggplot2)

#get list of file names
#path is in the OSC 
setwd("/fs/ess/PAS2136/BGNN/Minnows/Morphology/Presence/")
files <- list.files(pattern = '*.json')

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile)
  df <- as.data.frame(input)
  df$file.name <- gsub(jfile,
                       pattern = "_presence.json", 
                       replacement = "")
  return(df)
}

#test with one  file
test.file <- "INHS_FISH_003752_presence.json"
test <- json_df(jfile = test.file)
str(test)

presence.df <- lapply(files, json_df) %>% 
  dplyr::bind_rows()

names(presence.df) <- gsub(x = names(presence.df), 
                           pattern = "\\.", 
                           replacement = "_")  

#test that it is the same as Thibault
#Thibault used the following images: 62362, 99358, 103219, 106768, 47892, 25022, 24324, 56883, 43105, 95766
tt.df <- read.csv("https://raw.githubusercontent.com/hdr-bgnn/minnowTraits/main/Jupyter_Notebook/output.csv",
                  header = TRUE)

#differences in outputs....
colnames(tt.df)[colnames(tt.df) == "X"] <- "file_name"

colnames(tt.df)
colnames(presence.df)
setdiff(colnames(tt.df), colnames(presence.df))

#return to GitHub directory
setwd("/users/PAS2136/balkm/minnowTraits/Files")

write.csv(presence.df, "presence.absence.matrix.csv", row.names = FALSE)

#combine with metadata to get taxonomic heirarchy
meta.df <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE)
colnames(meta.df)
meta.df$original_file_name <- gsub(meta.df$original_file_name,
                                   pattern = ".jpg",
                                   replacement = "")

presence.meta <- merge(presence.df, meta.df, 
                       by.x = "file_name", by.y = "original_file_name", 
                       all.x = TRUE, all.y = FALSE)
#check df
nrow(presence.meta)
length(unique(presence.meta$scientific_name))

#get rid of columns we don't need
df <- select(presence.meta, - c("adipos_fin_number", "adipos_fin_percentage",
                                "caudal_fin_ray_number", "caudal_fin_ray_percentage",
                                "alt_fin_ray_number", "alt_fin_ray_percentage",
                                "width", "size", "height"))

## how many 0s are there?
no.abs <- df[apply(df, 1, function(row) all(row !=0 )), ]  # Remove zero-rows
nrow(df) - nrow(no.abs) #40

#about the data
stats <- df %>%
  summarise(min.head = min(head_percentage),
            max.head = max(head_percentage),
            min.trunk = min(trunk_percentage),
            max.trunk = max(trunk_percentage),
            min.eye = min(eye_percentage),
            max.eye = max(eye_percentage),
            min.dor = min(dorsal_fin_percentage),
            max.dor = max(dorsal_fin_percentage),
            min.caud = min(caudal_fin_percentage),
            max.caud = max(caudal_fin_percentage),
            min.anal = min(anal_fin_percentage),
            max.anal = max(anal_fin_percentage),
            min.pelv = min(pelvic_fin_percentage),
            max.pelv = max(pelvic_fin_percentage),
            min.pect = min(pectoral_fin_percentage),
            max.pect = max(pectoral_fin_percentage))
#most percentages are between .8 adn 1
#only caudal fin is low (0.45 as the smallest blob)

stats.sp <- df %>%
  group_by(scientific_name) %>%
  summarise(sample = n(),
            min.head = min(head_percentage),
            max.head = max(head_percentage),
            min.trunk = min(trunk_percentage),
            max.trunk = max(trunk_percentage),
            min.eye = min(eye_percentage),
            max.eye = max(eye_percentage),
            min.dor = min(dorsal_fin_percentage),
            max.dor = max(dorsal_fin_percentage),
            min.caud = min(caudal_fin_percentage),
            max.caud = max(caudal_fin_percentage),
            min.anal = min(anal_fin_percentage),
            max.anal = max(anal_fin_percentage),
            min.pelv = min(pelvic_fin_percentage),
            max.pelv = max(pelvic_fin_percentage),
            min.pect = min(pectoral_fin_percentage),
            max.pect = max(pectoral_fin_percentage)) %>%
  as.data.frame()

#make a heat map
row.names(stats.sp) <- stats.sp$scientific_name
stats.sp.trim <- stats.sp[,-c(1:2)]
stats.sp.trim <- as.matrix(stats.sp.trim)

hm <- heatmap(stats.sp.trim, 
              labRow = rownames(stats.sp.trim),
              labCol = colnames(stats.sp.trim), 
              main = "Heat Map")


stats.sp$min.caud #only see four small numbers
small.num.caud <- sort(stats.sp$min.caud, decreasing = FALSE)
smallest.caud <- small.num.caud[1:4]
stats.sp[stats.sp$min.caud %in% smallest.caud,]
#N. atherinoides, N. boops, N. heterodon, N. texanus
#sample sizes vary wildly (in order): 610, 188, 31, 97
#also have other small %

#a lot of species are missing fins, like dorsal, anal, pelvic, pectoral
#caudal, eye, trunk perform the best

nrow(presence.meta[presence.meta$dorsal_fin_percentage == 0,]) #13


#for analyses: 
#  - % blob by trait and then by sp
#  - create coefficient of variation

#visualize data
ggplot(data = presence.meta) +
  geom_density(aes(x = dorsal_fin_percentage, fill = scientific_name))
