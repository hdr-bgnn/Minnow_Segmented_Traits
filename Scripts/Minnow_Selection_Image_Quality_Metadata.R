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

#how many species and images in image metadata (mm.df)?
sampling.df$Selection_Criteria[1] <- "Metadata files"

length(unique(mm.df$arkID))
length(unique(mm.df$scientificName))

sampling.df$All_Minnows_Images_sp[1] <- paste0(length(unique(mm.df$arkID)),
                                               " (",
                                               length(unique(mm.df$scientificName)),
                                               ")")

#now reduce to Burress et al. 2017

length(unique(mm.df$arkID[mm.df$scientificName %in% b.sp]))
length(unique(mm.df$scientificName[mm.df$scientificName %in% b.sp]))

sampling.df$Burress_et_al._2017_Overlap_Images_sp[1] <- paste0(length(unique(mm.df$arkID[mm.df$scientificName %in% b.sp])),
                                                               " (",
                                                               length(unique(mm.df$scientificName[mm.df$scientificName %in% b.sp])),
                                                               ")")

#### 2. use image quality metadata to select for minnow images ----

sampling.df$Selection_Criteria[2] <- "Image Quality Metadata Selection"

minnow.keep <- mm.df[mm.df$specimenView == "left" | mm.df$specimenView == "9" & #facing left
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

length(unique(minnow.keep$arkID))
length(unique(minnow.keep$scientificName))

sampling.df$All_Minnows_Images_sp[2] <- paste0(length(unique(minnow.keep$arkID)),
                                               " (",
                                               length(unique(minnow.keep$scientificName)),
                                               ")")

#for Burress et al. 2017
length(unique(minnow.keep$arkID[minnow.keep$scientificName %in% b.sp]))
length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp]))

sampling.df$Burress_et_al._2017_Overlap_Images_sp[2] <- paste0(length(unique(minnow.keep$arkID[minnow.keep$scientificName %in% b.sp])),
                                                               " (",
                                                               length(unique(minnow.keep$scientificName[minnow.keep$scientificName %in% b.sp])),
                                                               ")")

#### 3. only INHS, UWZM ----

sampling.df$Selection_Criteria[3] <- "Only INHS or UWZM (none from UWZM)"

institutions <- c("INHS)", 
                  "UWZM")
images.minnows.trim <- minnow.keep[minnow.keep$imageOwnerInstitutionCode %in% institutions,]

unique(images.minnows.trim$ownerInstitutionCode.multi)
nrow(images.minnows.trim)
length(unique(images.minnows.trim$scientificName))

sampling.df$All_Minnows_Images_sp[3] <- paste0(nrow(images.minnows.trim),
                                               " (",
                                               length(unique(images.minnows.trim$scientificName)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.trim[images.minnows.trim$scientificName %in% b.sp,])
length(unique(images.minnows.trim$scientificName[images.minnows.trim$scientificName %in% b.sp]))

sampling.df$Burress_et_al._2017_Overlap_Images_sp[3] <- paste0(nrow(images.minnows.trim[images.minnows.trim$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.trim$scientificName[images.minnows.trim$scientificName %in% b.sp])),
                                                               ")")
#### 4. remove empty URLs ----

sampling.df$Selection_Criteria[4] <- "No empty URLs"

##ask if url is empty and remove if it is
#1) see if url resolves
#2) see if file is empty
#3) if resolves & not empty, keep the path
#4) remove all other paths

#test with a known url
##http://www.tubri.org/HDR/INHS/INHS_FISH_65294.jpg
##INHS_FISH_33814.jpg
test <- images.minnows.trim[images.minnows.trim$ARKID == "0040g17t",]
empty <- c()
for(i in 1:nrow(test)){
  if(!isTRUE(valid_url(test$accessURI[i]))){
    empty <- c(empty, test$accessURI[i])
  }
  else if(isTRUE(download_size(test$accessURI[i]) < 1048576)){ #smallest sized image we found
    empty <- c(empty, test$accessURI[i])
  }
  else{
    next
  }
}

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

length(empty) #28

images.minnows.resolve <- images.minnows.trim[!(images.minnows.trim$accessURI %in% empty),]

##new counts
nrow(images.minnows.resolve) 
length(unique(images.minnows.resolve$scientificName)) 

sampling.df$All_Minnows_Images_sp[4] <- paste0(nrow(images.minnows.resolve),
                                               " (",
                                               length(unique(images.minnows.resolve$scientificName)),
                                               ")")

##compared to Burress et al. 2017
nrow(images.minnows.resolve[images.minnows.resolve$scientificName %in% b.sp,]) #477
length(unique(images.minnows.resolve$scientificName[images.minnows.resolve$scientificName %in% b.sp])) #17

sampling.df$Burress_et_al._2017_Overlap_Images_sp[4] <- paste0(nrow(images.minnows.resolve[images.minnows.resolve$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.resolve$scientificName[images.minnows.resolve$scientificName %in% b.sp])),
                                                               ")")

#### 5. At least 10 samples ----

sampling.df$Selection_Criteria[5] <- "At least 10 samples"

#get sample size (number of images per species)
table.sp <- images.minnows.resolve %>%
  dplyr::group_by(scientificName) %>%
  dplyr::summarise(sample.size = n())
nrow(table.sp) #111

#retain only species for which there are 10 images
table.sp.10 <- table.sp$scientificName[table.sp$sample.size >= 10]
length(table.sp.10) #54 sp

#trim dataset to match species with at least 10 species
images.minnows.10 <- images.minnows.resolve[images.minnows.resolve$scientificName %in% table.sp.10,]
nrow(images.minnows.10) 
length(unique(images.minnows.10$scientificName)) 

sampling.df$All_Minnows_Images_sp[5] <- paste0(nrow(images.minnows.10),
                                               " (",
                                               length(unique(images.minnows.10$scientificName)),
                                               ")")

#compared to Burress et al. 2017
nrow(images.minnows.10[images.minnows.10$scientificName %in% b.sp,])
length(unique(images.minnows.10$scientificName[images.minnows.10$scientificName %in% b.sp]))

sampling.df$Burress_et_al._2017_Overlap_Images_sp[5] <- paste0(nrow(images.minnows.10[images.minnows.10$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(images.minnows.10$scientificName[images.minnows.10$scientificName %in% b.sp])),
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
