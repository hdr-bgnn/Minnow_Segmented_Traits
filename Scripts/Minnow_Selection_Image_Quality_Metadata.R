# selection of minnow images for the workflow
# Meghan Balk
# balk@battelleecology.org

library(dplyr) # to provide %>%

source("Scripts/init.R")

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

length(unique(iqm.df$ARKID)) #34795
length(unique(iqm.df$scientificName)) #804

sampling.df$All_Minnows_Images_sp[1] <- paste0(length(unique(iqm.df$ARKID)),
                                               " (",
                                               length(unique(iqm.df$scientificName)),
                                               ")")

#now reduce to Burress et al. 2017

length(unique(iqm.df$ARKID[iqm.df$scientificName %in% b.sp])) #1333
length(unique(iqm.df$scientificName[iqm.df$scientificName %in% b.sp])) #22

sampling.df$Burress_et_al._2017_Overlap_Images_sp[1] <- paste0(length(unique(iqm.df$ARKID[iqm.df$scientificName %in% b.sp])),
                                                               " (",
                                                               length(unique(iqm.df$scientificName[iqm.df$scientificName %in% b.sp])),
                                                               ")")

#### 2. selection based on IQM ----

sampling.df$Selection_Criteria[2] <- "Select for Minnows"

#extract just the minnows
minnow.iqm <-  iqm.df[iqm.df$family == "Cyprinidae",]
length(unique(minnow.iqm$ARKID)) #13842
length(unique(minnow.iqm$scientificName)) #166

sampling.df$All_Minnows_Images_sp[2] <- paste0(length(unique(minnow.iqm$ARKID)),
                                               " (",
                                               length(unique(minnow.iqm$scientificName)),
                                               ")")

##compared to Burress et al. 2017
length(unique(minnow.iqm$ARKID[minnow.iqm$scientificName %in% b.sp])) #1333
length(unique(minnow.iqm$scientificName[minnow.iqm$scientificName %in% b.sp])) #22

sampling.df$Burress_et_al._2017_Overlap_Images_sp[2] <- paste0(length(unique(minnow.iqm$ARKID[minnow.iqm$scientificName %in% b.sp])),
                                                               " (",
                                                               length(unique(minnow.iqm$scientificName[minnow.iqm$scientificName %in% b.sp])),
                                                               ")")

#### 3. use image quality metadata to select for minnow images ----

sampling.df$Selection_Criteria[3] <- "Image Quality Metadata Selection"

minnow.keep <- minnow.iqm[minnow.iqm$specimenView == "left" & #facing left
                          minnow.iqm$specimenCurved == "straight"&
                          minnow.iqm$brightness == "normal" &
                          minnow.iqm$colorIssue == "none" &
                          minnow.iqm$containsScaleBar == "True" &
                          minnow.iqm$partsOverlapping == "False" &
                          minnow.iqm$onFocus == "True" &
                          minnow.iqm$partsMissing == "False" &
                          minnow.iqm$allPartsVisible == "True" &
                          minnow.iqm$partsFolded == "False",]

length(unique(minnow.keep$ARKID)) #7811
length(unique(minnow.keep$scientificName)) #115

sampling.df$All_Minnows_Images_sp[3] <- paste0(length(unique(minnow.keep$ARKID)),
                                               " (",
                                               length(unique(minnow.keep$scientificName)),
                                               ")")

#for Burress et al. 2017
length(unique(minnow.keep$ARKID[minnow.keep$scientificName %in% b.sp])) #756
length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp])) #20

sampling.df$Burress_et_al._2017_Overlap_Images_sp[3] <- paste0(length(unique(minnow.keep$ARKID[minnow.keep$scientificName %in% b.sp])),
                                                               " (",
                                                               length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp])),
                                                               ")")

#we lose a lot of species when we include this
nrow(minnow.keep[minnow.keep$uniformBackground == "True",]) #3533
length(unique(minnow.keep$scientificName[minnow.keep$uniformBackground == "True"])) #99

#merge subset of image quality metadata with the image metadata
#combine metadata

images.minnows <- merge(meta.df, minnow.keep,
                        by = "ARKID")

#### 4. get rid of dupes ----
# image metadata has multiple users, so duplicates per fish

sampling.df$Selection_Criteria[4] <- "Removing dupes from image quality metadata file"

images.minnows.clean <- images.minnows[!duplicated(images.minnows$ARKID),]

#how many species and images in image metadata?
nrow(images.minnows.clean) #7810
length(unique(images.minnows.clean$scientificName.x)) #114

sampling.df$All_Minnows_Images_sp[4] <- paste0(nrow(images.minnows.clean),
                                               " (",
                                               length(unique(images.minnows.clean$scientificName.x)),
                                               ")")

#now reduce to Burress et al. 2017
nrow(images.minnows.clean[images.minnows.clean$scientificName.x %in% b.sp,]) #7565
length(unique(images.minnows.clean$scientificName.x[images.minnows.clean$scientificName.x %in% b.sp])) #19

sampling.df$Burress_et_al._2017_Overlap_Images_sp[4] <- paste0(nrow(images.minnows.clean[images.minnows.clean$scientificName.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.clean$scientificName.x[images.minnows.clean$scientificName.x %in% b.sp])),
                                                               ")")

#### 5. only INHS, UWZM ----

sampling.df$Selection_Criteria[5] <- "Only INHS or UWZM (none from UWZM)"

institutions <- c("INHS", "UWZM") #no uwzm
images.minnows.trim <- images.minnows.clean[images.minnows.clean$imageOwnerInstitutionCode.x %in% institutions,]
unique(images.minnows.trim$ownerInstitutionCode)
nrow(images.minnows.trim) #6481
length(unique(images.minnows.trim$scientificName.x)) #92

unique(images.minnows.trim$specimenQuantity)
#should be 1; don't want multiple fish per images because currently don't have a good way to keep metadata

sampling.df$All_Minnows_Images_sp[5] <- paste0(nrow(images.minnows.trim),
                                               " (",
                                               length(unique(images.minnows.trim$scientificName.x)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.trim[images.minnows.trim$scientificName.x %in% b.sp,]) #477
length(unique(images.minnows.trim$scientificName.x[images.minnows.trim$scientificName.x %in% b.sp])) #17

sampling.df$Burress_et_al._2017_Overlap_Images_sp[5] <- paste0(nrow(images.minnows.trim[images.minnows.trim$scientificName.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.trim$scientificName.x[images.minnows.trim$scientificName.x %in% b.sp])),
                                                               ")")
#### 6. remove empty URLs ----

sampling.df$Selection_Criteria[6] <- "No empty URLs"

##ask if url is empty and remove if it is
#1) see if url resolves
#2) see if file is empty
#3) if resolves & not empty, keep the path
#4) remove all other paths

# Filter images to those with scientificName in Burress data
images.minnows.trim <- images.minnows.trim[images.minnows.trim$scientificName.x %in% b.sp,]

## Ensure all image URLs work
empty <- c()
for(i in 1:nrow(images.minnows.trim)){
  if(!isTRUE(valid_url(images.minnows.trim$accessURI[i]))){
    empty <- c(empty, images.minnows.trim$accessURI[i])
  }
  else if(isTRUE(download_size(images.minnows.trim$accessURI[i]) < 1048576)){ #smallest sized image we found
    empty <- c(empty, images.minnows.trim$accessURI[i])
  }
  else{
    next
  }
}

images.minnows.resolve <- images.minnows.trim[!(images.minnows.trim$accessURI %in% empty),]

##new counts
nrow(images.minnows.resolve) #6479
length(unique(images.minnows.resolve$scientificName.x)) #92

sampling.df$All_Minnows_Images_sp[6] <- paste0(nrow(images.minnows.resolve),
                                               " (",
                                               length(unique(images.minnows.resolve$scientificName.x)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.resolve[images.minnows.resolve$scientificName.x %in% b.sp,]) #477
length(unique(images.minnows.resolve$scientificName.x[images.minnows.resolve$scientificName.x %in% b.sp])) #17

sampling.df$Burress_et_al._2017_Overlap_Images_sp[6] <- paste0(nrow(images.minnows.resolve[images.minnows.resolve$scientificName.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.resolve$scientificName.x[images.minnows.resolve$scientificName.x %in% b.sp])),
                                                               ")")

#### 7. At least 10 samples ----

sampling.df$Selection_Criteria[7] <- "At least 10 samples"

#get sample size (number of images per species)
table.sp <- images.minnows.resolve %>%
  group_by(scientificName.x) %>%
  summarise(sample.size = n())
nrow(table.sp) #92 sp

#retain only species for which there are 10 images
table.sp.10 <- table.sp$scientificName.x[table.sp$sample.size >= 10]
length(table.sp.10) #41 sp

#trim dataset to match species with at least 10 species
images.minnows.10 <- images.minnows.resolve[images.minnows.resolve$scientificName.x %in% table.sp.10,]
nrow(images.minnows.10) #6300
length(unique(images.minnows.10$scientificName.x)) #41

sampling.df$All_Minnows_Images_sp[7] <- paste0(nrow(images.minnows.10),
                                               " (",
                                               length(unique(images.minnows.10$scientificName.x)),
                                               ")")

#compared to Burress et al. 2017
nrow(images.minnows.10[images.minnows.10$scientificName.x %in% b.sp,]) #446
length(unique(images.minnows.10$scientificName.x[images.minnows.10$scientificName.x %in% b.sp])) #8

sampling.df$Burress_et_al._2017_Overlap_Images_sp[7] <- paste0(nrow(images.minnows.10[images.minnows.10$scientificName.x %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.10$scientificName.x[images.minnows.10$scientificName.x %in% b.sp])),
                                                               ")")

### limit species
if(isTRUE(checkpoint.limit_image == "")){
  images.minnows.limit <- images.minnows.10
} else if(isTRUE(is.integer(checkpoint.limit_image))){
  images.minnows.limit <- head(images.minnows.10, n=checkpoint.limit_image)
} else {
  print("The value for limit_image is invalid. Accepted values are '' or an integer.")
}

#### write datasets ----

#write dataset to Burress
write.csv(images.minnows.limit,
          file = burress_minnow_filtered_path,
          row.names = FALSE)

#write table of sampling
write.csv(sampling.df,
          file = sampling_path,
          row.names = FALSE)
