# Minnow Traits
# Meghan Balk 
# balk@battelleecology.org

library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)

####LOAD DATA----

## already segmented images from Maruf
ml.fish.data <- read.csv("fish.meta.qual.tax.csv", header = TRUE) #images that have already run through the ML algorithm

##image metadata and image quality metadata from Yasin
image.data <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE) #images with metadata
image.quality <- read.csv("Image_Quality_Metadata_v1_20211206_151204.csv", header = TRUE)

##combing metadata
#link on image.data$file_name and image.quality$image_name

##select based on the following criteria:
#facing left
#only INHS, UWZM
#contrast?
#minnows

images.keep <- image.quality[image.quality$family == "Cyprinidae" &
                              image.quality$specimen_viewing == "left" &
                              image.quality$straight_curved == "straight"&
                              image.quality$brightness == "normal" &
                              image.quality$color_issues == "none" &
                              image.quality$has_ruler == "True" &
                              image.quality$if_overlapping == "False" &
                              image.quality$if_focus == "True" &
                              image.quality$has_ruler == "True",] 

nrow(images.keep[images.keep$if_background_uniform == "True",]) #4814

nrow(images.keep) #13848

images.minnows <- merge(images.keep, image.data, by.x = "image_name", by.y = "original_file_name")

#extract only the Minnows
minnows <- image.data[image.data$family == "Cyprinidae",] %>% drop_na()
minnow.noDupe <- minnows[!duplicated(minnows$catalog_id),] %>% drop_na() #get rid of duplicates

minnows.ml <- ml.fish.data[ml.fish.data$family == "Cyprinidae",] %>% drop_na()
minnows.ml.noDupe <- minnows.ml[!duplicated(minnows.ml$catalog_id),] %>% drop_na()

#get counts
nrow(minnows) #42382
nrow(minnow.noDupe) #23750 #WHY SO MANY DUPLICATES??

nrow(minnows.ml) #19232
nrow(minnows.ml.noDupe) #11925 #WHY SO MANY DUPLICATES??

##focus only on the outputs from the ML
counts <- table(minnows.ml.noDupe$scientific_name)
length(counts) #134
length(counts[counts > 10]) #62

####TRIM DATASET----
#select out only INHS and UWZM because they are the most consistent
institutions <- c("INHS", "UWZM")
minnows.trim <- minnows.ml.noDupe[minnows.ml.noDupe$institution.y %in% institutions, ] %>% drop_na()
nrow(minnows.trim) #11340

#get counts
minnow.counts <- table(minnows.trim$scientific_name) 
length(minnow.counts) #111 sp
length(minnow.counts[minnow.counts > 10]) #53

## now look at "good quality" images
# left facing
# correct number of blobs, especially for eye and head

#only minnows facing left
minnows.left <- minnows.trim[minnows.trim$specimen_viewing == "left",] %>% drop_na()
nrow(minnows.left) #11037
counts.left <- table(minnows.left$scientific_name)
length(counts.left) #111
length(counts.left[counts.left > 10]) #53

#only segmented images with one blob for head and eye (i.e., only found one head and one eye)
minnows.blobs <- minnows.left[minnows.left$CC.HEAD == 1 &
                              minnows.left$CC.EYE == 1,] %>% drop_na()
nrow(minnows.blobs) #10377
counts.trim <- table(minnows.blobs$scientific_name)
length(counts.trim) #111
length(counts.trim[counts.trim > 10]) #51
sum(counts.trim[counts.trim > 10]) #10167

write.csv(minnows.blobs, "minnows.selected.csv")