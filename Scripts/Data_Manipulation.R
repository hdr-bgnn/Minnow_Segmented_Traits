# set paths for files
# Meghan Balk
# balk@battelleecology.org

#### read yaml file ----
dfs <- yaml::read_yaml(file = config_file)
checkpoint.limit_image <- dfs$limit_images

meta.df <- read.csv(file = dfs$Image_Metadata)

iqm.df <- read.csv(file = dfs$Image_Quality_Metadata)

multi.df <- read.csv(file = dfs$Multimedia)

b.df <- read.csv(file = dfs$Burress)

# Output file paths
minnow_filtered_path <- dfs$Minnow_Filtered
burress_minnow_filtered_path <- dfs$Burress_Minnow_Filtered
sampling_path <- dfs$Sampling
presence_absence_matrix_path <- dfs$Presence_Absence_Matrix
sampling_species_burress_path <- dfs$Sampling_Species_Burress
sampling_minnows_seg_path <- dfs$Sampling_Minnows_Seg
sampling_df_seg_path <- dfs$Sampling_DF_Seg
presence_absence_dist_path <- dfs$Presence_Absence_Dist_Image
heatmap_avg_blob_path <- dfs$Heatmap_Avg_Blob_Image
heatmap_sd_blob_path <- dfs$Heatmap_SD_Blob_Image


#### manipulate data ----

## metadata image files
# downloaded from https://bgnn.tulane.edu/hdrweb/hdr/imagemetadata/
# meta is metadata about the images
# iqm is metadata about image quality
# multi is metadata about the multimedia files

#fix meta arkId to arkID
colnames(meta.df)[colnames(meta.df) == "arkId"] <- "arkID"

# will combine all the files to one metadata file for ease of use
meta.iqm <- dplyr::left_join(meta.df, iqm.df,
                             by = "arkID",
                             suffix = c("", ".iqm"))
meta.multi <- dplyr::left_join(meta.iqm, multi.df,
                               by = "arkID",
                               suffix = c("", ".multi"))
mm1 <- meta.multi %>% 
  dplyr::mutate(fileNameAsDelivered = ifelse(is.na(fileNameAsDelivered), fileNameAsDelivered.multi, fileNameAsDelivered))
mm.df <- mm1 %>% 
  dplyr::select(-fileNameAsDelivered.multi)

#how many rows have empty iqm fields? using "quality" to test
nrow(mm.df) #42423
nrow(mm.df %>% 
       tidyr::drop_na(quality)) #20719
#difference: 21704 without IQM data

# remove ".jpg" from file name to more easily align with file name in presence.df
mm.df$fileNameAsDelivered <- gsub(meta.df$fileNameAsDelivered,
                                  pattern = ".jpg",
                                  replacement = "")

## burress previous measurements
# measurements from Burress et al. 2017 (see PDFs/Burress et al. 2017  Ecological diversification associated with the benthic‐to‐pelagic transition supinfo.docx)
b.df <- read.csv(file = file.path(files, "Previous Fish Measurements - Burress et al. 2016.csv"),
                 head = TRUE)

# create list of species
b.sp <- unique(b.df$Species)

# label measurements with "b_" to show they're from Burress et al. 2017

names(b.df)[2:10] <- paste0("b.",names(b.df)[2:10])

