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
sampling.df = data.frame(matrix(nrow = 7, ncol = length(c.names)))
colnames(sampling.df) = c.names

#### 1. sampling of the metadata ----

#how many species and images in image metadata (mm.df)?
sampling.df$Selection_Criteria[1] <- "Metadata files"

nrow(mm.df) #20720
length(unique(mm.df$scientificName)) #188

sampling.df$All_Minnows_Images_sp[1] <- paste0(nrow(mm.df),
                                               " (",
                                               length(unique(mm.df$scientificName)),
                                               ")")

#now reduce to Burress et al. 2017

nrow(mm.df[mm.df$scientificName %in% b.sp,]) #2818
length(unique(mm.df$scientificName[mm.df$scientificName %in% b.sp])) #22

sampling.df$Burress_et_al._2017_Overlap_Images_sp[1] <- paste0(nrow(mm.df[mm.df$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(mm.df$scientificName[mm.df$scientificName %in% b.sp])),
                                                               ")")

#### 2. use image quality metadata to select for minnow images ----

sampling.df$Selection_Criteria[2] <- "Image Quality Metadata Selection"

minnow.keep <- mm.df[mm.df$specimenView == "left" & 
                     mm.df$specimenCurved == "straight"&
                     mm.df$brightness == "normal" &
                     mm.df$colorIssue == "none" &
                     mm.df$containsScaleBar == "True" & 
                     mm.df$partsOverlapping == "False" &
                     mm.df$onFocus == "True" &
                     mm.df$partsMissing == "False" &
                     mm.df$allPartsVisible == "True" &
                     mm.df$partsFolded == "False" &
                     mm.df$uniformBackground == "True",]

nrow(minnow.keep) #3656
length(unique(minnow.keep$scientificName)) #98

sampling.df$All_Minnows_Images_sp[2] <- paste0(nrow(minnow.keep),
                                               " (",
                                               length(unique(minnow.keep$scientificName)),
                                               ")")

#for Burress et al. 2017
nrow(minnow.keep[minnow.keep$scientificName %in% b.sp,]) #595
length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp])) #16

sampling.df$Burress_et_al._2017_Overlap_Images_sp[2] <- paste0(nrow(minnow.keep[minnow.keep$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp])),
                                                               ")")

#### 3. only INHS, UWZM ----

sampling.df$Selection_Criteria[3] <- "Only INHS or UWZM (none from UWZM)"

institutions <- c("INHS", 
                  "UWZM")
images.minnows.trim <- minnow.keep[minnow.keep$imageOwnerInstitutionCode %in% institutions,]

unique(images.minnows.trim$imageOwnerInstitutionCode)
nrow(images.minnows.trim) #2059
length(unique(images.minnows.trim$scientificName)) #72

sampling.df$All_Minnows_Images_sp[3] <- paste0(nrow(images.minnows.trim),
                                               " (",
                                               length(unique(images.minnows.trim$scientificName)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.trim[images.minnows.trim$scientificName %in% b.sp,]) #273
length(unique(images.minnows.trim$scientificName[images.minnows.trim$scientificName %in% b.sp])) #13

sampling.df$Burress_et_al._2017_Overlap_Images_sp[3] <- paste0(nrow(images.minnows.trim[images.minnows.trim$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.trim$scientificName[images.minnows.trim$scientificName %in% b.sp])),
                                                               ")")

### limit species
if(isTRUE(checkpoint.limit_image == "")){
  images.minnows.limit <- images.minnows.trim
} else if(isTRUE(is.integer(checkpoint.limit_image))){
  images.minnows.limit <- head(images.minnows.trim, n=checkpoint.limit_image)
} else {
  print("The value for limit_image is invalid. Accepted values are '' or an integer.")
}

#### write datasets ----

#write dataset to Burress
write.csv(images.minnows.limit,
          file = minnow_filtered_path,
          row.names = FALSE)

#write dataset trimmed to Burress
images.minnows.burress <- images.minnows.limit[images.minnows.limit$scientificName %in% b.sp,]
write.csv(images.minnows.burress,
          file = burress_minnow_filtered_path,
          row.names = FALSE)

#write table of sampling
write.csv(sampling.df,
          file = sampling_path,
          row.names = FALSE)
