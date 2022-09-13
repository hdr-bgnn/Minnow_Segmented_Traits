# set paths for files
# Meghan Balk 
# balk@battelleecology.org

#### read yaml file ----
dfs <- yaml::read_yaml(file = config_file)

meta.df <- read.csv(file = dfs$Image_Metadata[1])

iqm.df <- read.csv(file = dfs$Image_Quality_Metadata[1])

b.df <- read.csv(file = dfs$Burress[1])

# Output file paths
minnow_filtered_path <- dfs$Minnow_Filtered[1]
burress_minnow_filtered_path <- dfs$Burress_Minnow_Filtered[1]
sampling_path <- dfs$Sampling[1]
presence_absence_matrix_path <- dfs$Presence_Absence_Matrix[1]
sampling_species_burress_path <- dfs$Sampling_Species_Burress[1]
sampling_minnows_seg_path <- dfs$Sampling_Minnows_Seg[1]
sampling_df_seg_path <- dfs$Sampling_DF_Seg[1]
presence_absence_dist_path <- dfs$Presence_Absence_Dist_Image[1]
heatmap_avg_blob_path <- dfs$Heatmap_Avg_Blob_Image[1]
heatmap_sd_blob_path <- dfs$Heatmap_SD_Blob_Image[1]


#### manipulate data ----

## metadata image files
# downloaded from https://bgnn.tulane.edu/hdrweb/hdr/imagemetadata/
# meta.data is metadata about the images
# iqm is metadata about image quality

# remove ".jpg" from file name to more easily align with file name in presence.df
meta.df$original_file_name <- gsub(meta.df$original_file_name,
                                   pattern = ".jpg",
                                   replacement = "")

iqm.df$image_name <- gsub(iqm.df$image_name,
                          pattern = "\\..*",
                          replacement = "")

## burress previous measurements
# measurements from Burress et al. 2017 (see PDFs/Burress et al. 2017  Ecological diversification associated with the benthic‐to‐pelagic transition supinfo.docx)
b.df <- read.csv(file = file.path(files, "Previous Fish Measurements - Burress et al. 2016.csv"),
                 head = TRUE)

# create list of species
b.sp <- unique(b.df$Species)

# label measurements with "b_" to show they're from Burress et al. 2017

names(b.df)[2:10] <- paste0("b.",names(b.df)[2:10])

