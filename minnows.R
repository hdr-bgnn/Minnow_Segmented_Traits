# Minnow Traits
# Meghan Balk 
# balk@battelleecology.org

library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)

####LOAD DATA----

##image metadata and image quality metadata from Yasin
image.data <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE) #images with metadata
image.quality <- read.csv("Image_Quality_Metadata_v1_20211206_151204.csv", header = TRUE)

##combing metadata
#link on image.data$file_name and image.quality$image_name
#must have "original_file_name" for snakemake

images.keep <- image.quality[image.quality$family == "Cyprinidae" & #Minnows
                             image.quality$specimen_viewing == "left" & #facing left
                             image.quality$straight_curved == "straight"&
                             image.quality$brightness == "normal" &
                             image.quality$color_issues == "none" &
                             image.quality$has_ruler == "True" &
                             image.quality$if_overlapping == "False" &
                             image.quality$if_focus == "True" &
                             image.quality$if_missing_parts == "False" &
                             image.quality$if_parts_visible == "True" &
                             image.quality$fins_folded_oddly == "False",] 

nrow(images.keep) #10312

nrow(images.keep[images.keep$if_background_uniform == "True",]) #3533

images.minnows <- merge(image.data, images.keep, by.x = "original_file_name", by.y = "image_name")

#only INHS, UWZM
institutions <- c("INHS", "UWZM") #no uwzm
images.minnows.trim <- images.minnows[images.minnows$institution %in% institutions,]
nrow(images.minnows.trim) #8965

unique(images.minnows.trim$fish_number) #should be 1; don't want multiple fish per images because currently don't have a good way to keep metadata

#get rid of dupes!! image metadata has multiple users, so duplicates per fish
images.minnows.clean <- images.minnows.trim[!duplicated(images.minnows.trim$original_file_name),]
nrow(images.minnows.clean) #6482

#get sample size (number of images per species)
table.sp <- images.minnows.clean %>%
  group_by(scientific_name.x) %>%
  summarise(sample.size = n())
nrow(table.sp) #93 sp

#retain only species for which there are 10 images
table.sp.10 <- table.sp$scientific_name.x[table.sp$sample.size >= 10]
length(table.sp.10) #41 sp

#trim dataset to match species with at least 10 species
images.minnows.10 <- images.minnows.clean[images.minnows.clean$scientific_name.x %in% table.sp.10,]
nrow(images.minnows.10) #6302

table.gen <- images.minnows.10 %>%
  group_by(genus.x) %>%
  summarise(sample.size = n())
nrow(table.gen) #4
unique(images.minnows.10$genus.x)

#write dataset without index
write.csv(images.minnows.10, "minnow.images.for.segmenting.csv", row.names = FALSE)
