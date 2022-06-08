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

#extract just the minnows
minnow.quality <-  image.quality[image.quality$family == "Cyprinidae",]
nrow(minnow.quality) #20510
length(unique(minnow.quality$scientific_name)) #166

minnow.keep <- minnow.quality[minnow.quality$specimen_viewing == "left" & #facing left
                              minnow.quality$straight_curved == "straight"&
                              minnow.quality$brightness == "normal" &
                              minnow.quality$color_issues == "none" &
                              minnow.quality$has_ruler == "True" &
                              minnow.quality$if_overlapping == "False" &
                              minnow.quality$if_focus == "True" &
                              minnow.quality$if_missing_parts == "False" &
                              minnow.quality$if_parts_visible == "True" &
                              minnow.quality$fins_folded_oddly == "False",] 

nrow(minnow.keep) #10312
length(unique(minnow.keep$scientific_name)) #115

#we lose a lot of species when we include this
nrow(minnow.keep[minnow.keep$if_background_uniform == "True",]) #3533
length(unique(minnow.keep$scientific_name[minnow.keep$if_background_uniform == "True"])) #99

#merge subset of image quality metadata with the image metadata
images.minnows <- merge(image.data, minnow.keep, by.x = "original_file_name", by.y = "image_name")


#get rid of dupes!! image metadata has multiple users, so duplicates per fish
images.minnows.clean <- images.minnows[!duplicated(images.minnows$original_file_name),]
nrow(images.minnows.clean) #7811

#only INHS, UWZM
institutions <- c("INHS", "UWZM") #no uwzm
images.minnows.trim <- images.minnows.clean[images.minnows.clean$institution %in% institutions,]
nrow(images.minnows.trim) #6482
length(unique(images.minnows.trim$scientific_name.x)) #93

unique(images.minnows.trim$fish_number) 
#should be 1; don't want multiple fish per images because currently don't have a good way to keep metadata

#get sample size (number of images per species)
table.sp <- images.minnows.trim %>%
  group_by(scientific_name.x) %>%
  summarise(sample.size = n())
nrow(table.sp) #93 sp

#retain only species for which there are 10 images
table.sp.10 <- table.sp$scientific_name.x[table.sp$sample.size >= 10]
length(table.sp.10) #41 sp

#trim dataset to match species with at least 10 species
images.minnows.10 <- images.minnows.trim[images.minnows.trim$scientific_name.x %in% table.sp.10,]
nrow(images.minnows.10) #6302

table.gen <- images.minnows.10 %>%
  group_by(genus.x) %>%
  summarise(sample.size = n())
nrow(table.gen) #4
unique(images.minnows.10$genus.x)

#write dataset without index
write.csv(images.minnows.10, "minnow.images.for.segmenting.csv", row.names = FALSE)
