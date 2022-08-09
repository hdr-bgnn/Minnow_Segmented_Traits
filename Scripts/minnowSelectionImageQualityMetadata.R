# selection of minnow images for the workflow
# Meghan Balk 
# balk@battelleecology.org

## MAKE SURE WD IS IN REPO
#setwd("minnowTraits")

#### load dependencies ----
source("paths.R")
source("dependencies.R")

#### load functions ----
source(file.path(scripts, "json_df.R"))
source(file.path(scripts, "valid_url.R"))
source(file.path(scripts, "download_size.R"))

# Files created by this script:
# 1. table of sampling as selection criteria applied
# 2. new data set that only keeps images that meet the selection criteria
# 3. new data set that only keeps images that meet the selection criteria and
#    that contain the species in Burress et al. 2017

#### create table to be appended ----
c.names <- c("Selection_Criteria", 
             "All_Minnows_Images_sp",
             "Burress_et_al._2017_Overlap_Images_sp")
sampling.df = data.frame(matrix(nrow = 15, ncol = length(c.names))) 
colnames(sampling.df) = c.names

#### 1. sampling of the metadata ----

#how many species and images in image metadata?
sampling.df$Selection_Criteria[1] <- "Image quality metadata file"
#length(unique(image.data$file_name)) #109421
#length(unique(image.data$scientific_name)) #13664

length(unique(image.quality$image_name)) #34795
length(unique(image.quality$scientific_name)) #804

sampling.df$All_Minnows_Images_sp[1] <- paste0(length(unique(image.quality$image_name)),
                                               " (",
                                               length(unique(image.quality$scientific_name)),
                                               ")")

#now reduce to Burress et al. 2017
#length(unique(image.data$file_name[image.quality$scientific_name %in% b.sp])) #4114
#length(unique(image.data$scientific_name[image.data$scientific_name %in% b.sp])) #22

length(unique(image.quality$image_name[image.quality$scientific_name %in% b.sp])) #1333
length(unique(image.quality$scientific_name[image.quality$scientific_name %in% b.sp])) #22

sampling.df$Burress_et_al._2017_Overlap_Images_sp[1] <- paste0(length(unique(image.quality$image_name[image.quality$scientific_name %in% b.sp])),
                                                               " (",
                                                               length(unique(image.quality$scientific_name[image.quality$scientific_name %in% b.sp])),
                                                               ")")

#### 2. selection based on IQM ----

sampling.df$Selection_Criteria[2] <- "Select for Minnows"

#extract just the minnows
minnow.quality <-  image.quality[image.quality$family == "Cyprinidae",]
length(unique(minnow.quality$image_name)) #13842
length(unique(minnow.quality$scientific_name)) #166

sampling.df$All_Minnows_Images_sp[2] <- paste0(length(unique(minnow.quality$image_name)),
                                               " (",
                                               length(unique(minnow.quality$scientific_name)),
                                               ")")

##compared to Burress et al. 2017
length(unique(minnow.quality$image_name[minnow.quality$scientific_name %in% b.sp])) #1333
length(unique(minnow.quality$scientific_name[minnow.quality$scientific_name %in% b.sp])) #22

sampling.df$Burress_et_al._2017_Overlap_Images_sp[2] <- paste0(length(unique(minnow.quality$image_name[minnow.quality$scientific_name %in% b.sp])),
                                                               " (",
                                                               length(unique(minnow.quality$scientific_name[minnow.quality$scientific_name %in% b.sp])),
                                                               ")")

#### 3. use image quality metadata to select for minnow images ----

sampling.df$Selection_Criteria[3] <- "Image Quality Metadata Selection"

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

length(unique(minnow.keep$image_name)) #7811
length(unique(minnow.keep$scientific_name)) #115

sampling.df$All_Minnows_Images_sp[3] <- paste0(length(unique(minnow.keep$image_name)),
                                               " (",
                                               length(unique(minnow.keep$scientific_name)),
                                               ")")

#for Burress et al. 2017
length(unique(minnow.keep$image_name[minnow.keep$scientific_name %in% b.sp])) #756
length(unique(minnow.keep$scientific_name[minnow.keep$scientific_name %in% b.sp])) #20

sampling.df$Burress_et_al._2017_Overlap_Images_sp[3] <- paste0(length(unique(minnow.keep$image_name[minnow.keep$scientific_name %in% b.sp])),
                                                               " (",
                                                               length(unique(minnow.keep$scientific_name[minnow.keep$scientific_name %in% b.sp])),
                                                               ")")

#we lose a lot of species when we include this
nrow(minnow.keep[minnow.keep$if_background_uniform == "True",]) #3533
length(unique(minnow.keep$scientific_name[minnow.keep$if_background_uniform == "True"])) #99

#merge subset of image quality metadata with the image metadata
#combine metadata
#link on image.data$file_name and image.quality$image_name
#must have "original_file_name" for snakemake

images.minnows <- merge(image.data, minnow.keep, by.x = "original_file_name", by.y = "image_name")

#### 4. get rid of dupes ----
# image metadata has multiple users, so duplicates per fish

sampling.df$Selection_Criteria[4] <- "Removing dupes from image quality metadata file"

images.minnows.clean <- images.minnows[!duplicated(images.minnows$original_file_name),]

#how many species and images in image metadata?
nrow(images.minnows.clean) #7811
length(unique(images.minnows.clean$scientific_name.x)) #115

sampling.df$All_Minnows_Images_sp[4] <- paste0(nrow(images.minnows.clean),
                                               " (",
                                               length(unique(images.minnows.clean$scientific_name.x)),
                                               ")")

#now reduce to Burress et al. 2017
nrow(images.minnows.clean[images.minnows.clean$scientific_name.x %in% b.sp,]) #756
length(unique(images.minnows.clean$scientific_name.x[images.minnows.clean$scientific_name.x %in% b.sp])) #20

sampling.df$Burress_et_al._2017_Overlap_Images_sp[4] <- paste0(nrow(images.minnows.clean[images.minnows.clean$scientific_name.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.clean$scientific_name.x[images.minnows.clean$scientific_name.x %in% b.sp])),
                                                               ")")

#### 5. only INHS, UWZM ----

sampling.df$Selection_Criteria[5] <- "Only INHS or UWZM (none from UWZM)"

institutions <- c("INHS", "UWZM") #no uwzm
images.minnows.trim <- images.minnows.clean[images.minnows.clean$institution %in% institutions,]
unique(images.minnows.trim$institution)
nrow(images.minnows.trim) #6482
length(unique(images.minnows.trim$scientific_name.x)) #93

unique(images.minnows.trim$fish_number) 
#should be 1; don't want multiple fish per images because currently don't have a good way to keep metadata

sampling.df$All_Minnows_Images_sp[5] <- paste0(nrow(images.minnows.trim),
                                               " (",
                                               length(unique(images.minnows.trim$scientific_name.x)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.trim[images.minnows.trim$scientific_name.x %in% b.sp,]) #478
length(unique(images.minnows.trim$scientific_name.x[images.minnows.trim$scientific_name.x %in% b.sp])) #18

sampling.df$Burress_et_al._2017_Overlap_Images_sp[5] <- paste0(nrow(images.minnows.trim[images.minnows.trim$scientific_name.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.trim$scientific_name.x[images.minnows.trim$scientific_name.x %in% b.sp])),
                                                               ")")
#### 6. remove empty URLs ----

sampling.df$Selection_Criteria[6] <- "No empty URLs"

##ask if url is empty and remove if it is
#1) see if url resolves
#2) see if file is empty
#3) if resolves & not empty, keep the path
#4) remove all other paths

#test with a known url that doesn't work
##http://www.tubri.org/HDR/INHS/INHS_FISH_65294.jpg
##INHS_FISH_33814.jpg
test <- images.minnows.trim[images.minnows.trim$original_file_name == "INHS_FISH_33814.jpg" |
                            images.minnows.trim$path == "http://www.tubri.org/HDR/INHS/INHS_FISH_65294.jpg",]

## now for all:
empty <- c()
for(i in 1:nrow(images.minnows.trim)){
  if(!isTRUE(valid_url(images.minnows.trim$path[i]))){
    empty <- c(empty, images.minnows.trim$path[i])
  }
  else if(isTRUE(download_size(images.minnows.trim$path[i]) < 1048576)){ #smallest sized image we found
    empty <- c(empty, images.minnows.trim$path[i])
  }
  else{
    next
  }
}

images.minnows.resolve <- images.minnows.trim[!(images.minnows.trim$path %in% empty),]

##new counts
nrow(images.minnows.resolve) #6480
length(unique(images.minnows.resolve$scientific_name.x)) #93

sampling.df$All_Minnows_Images_sp[6] <- paste0(nrow(images.minnows.resolve),
                                               " (",
                                               length(unique(images.minnows.resolve$scientific_name.x)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.resolve[images.minnows.resolve$scientific_name.x %in% b.sp,]) #478
length(unique(images.minnows.resolve$scientific_name.x[images.minnows.resolve$scientific_name.x %in% b.sp])) #17

sampling.df$Burress_et_al._2017_Overlap_Images_sp[6] <- paste0(nrow(images.minnows.resolve[images.minnows.resolve$scientific_name.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.resolve$scientific_name.x[images.minnows.resolve$scientific_name.x %in% b.sp])),
                                                               ")")

#### 7. At least 10 samples ----

sampling.df$Selection_Criteria[7] <- "At least 10 samples"

#get sample size (number of images per species)
table.sp <- images.minnows.resolve %>%
  group_by(scientific_name.x) %>%
  summarise(sample.size = n())
nrow(table.sp) #93 sp

#retain only species for which there are 10 images
table.sp.10 <- table.sp$scientific_name.x[table.sp$sample.size >= 10]
length(table.sp.10) #41 sp

#trim dataset to match species with at least 10 species
images.minnows.10 <- images.minnows.resolve[images.minnows.resolve$scientific_name.x %in% table.sp.10,]
nrow(images.minnows.10) #6300
length(unique(images.minnows.10$scientific_name.x)) #41

sampling.df$All_Minnows_Images_sp[7] <- paste0(nrow(images.minnows.10),
                                               " (",
                                               length(unique(images.minnows.10$scientific_name.x)),
                                               ")")

#compared to Burress et al. 2017
nrow(images.minnows.10[images.minnows.10$scientific_name.x %in% b.sp,]) #446
length(unique(images.minnows.10$scientific_name.x[images.minnows.10$scientific_name.x %in% b.sp])) #8

sampling.df$Burress_et_al._2017_Overlap_Images_sp[7] <- paste0(nrow(images.minnows.10[images.minnows.10$scientific_name.x %in% b.sp,]),
                                                               " (", 
                                                               length(unique(images.minnows.10$scientific_name.x[images.minnows.10$scientific_name.x %in% b.sp])),
                                                               ")")

#### write datasets ----

#write dataset without index
write.csv(images.minnows.10, 
          file = file.path(results, paste0("minnow.filtered.from.imagequalitymetadata_", Sys.Date(),".csv")), 
          row.names = FALSE)

#write dataset trimmed to Burress
images.minnows.burress <- images.minnows.10[images.minnows.10$scientific_name.x %in% b.sp,]
write.csv(images.minnows.burress, 
          file = file.path(results, paste0("burress.minnow.sp.filtered.from.imagequalitymetadata_", Sys.Date(), ".csv")),
          row.names = FALSE)

#write table of sampling
write.csv(sampling.df,
          file = file.path(restults, "sampling.df.IQM.csv"),
          row.names = FALSE)
