# set paths for files
# Meghan Balk 
# balk@battelleecology.org

#put directory to cloned repo
library <- "Library" # library for version of R packages
scripts <- "Scripts" # folder with scripts
files <- "Files" # folder with files to read into scripts
results <- "Results" # folder to store outputs of scripts
presence <- file.path("Morphology", "Presence") #this would be whatever snakemake produces. what folder would this be in?
measure <- file.path("Morphology", "Measure") #this would be whatever snakemake produces. what folder would this be in?

## metadata image files
# downloaded from https://bgnn.tulane.edu/hdrweb/hdr/imagemetadata/
# meta.data is metadata about the images
# iqm is metadata about image quality

meta.df <- read.csv(file = file.path(files, "Image_Metadata_v1_20211206_151152.csv"), 
                    header = TRUE)
iqm.df <- read.csv(file = file.path(files, "Image_Quality_Metadata_v1_20211206_151204.csv"),
                   header = TRUE)

#remove ".jpg" from file name to more easily align with file name in presence.df
meta.df$original_file_name <- gsub(meta.df$original_file_name,
                                   pattern = ".jpg",
                                   replacement = "")

iqm.df$image_name <- gsub(iqm.df$image_name,
                          pattern = "\\..*",
                          replacement = "")

## burress previous measurements
# measurements from Burress et al. 2017 (see PDFs/Burress et al 2017  Ecological diversification associated with the benthic‐to‐pelagic transition supinfo.docx)
b.df <- read.csv(file = file.path(files, "Previous Fish Measurements - Burress et al. 2016.csv"),
                 head = TRUE)
b.sp <- unique(b.df$Species)
