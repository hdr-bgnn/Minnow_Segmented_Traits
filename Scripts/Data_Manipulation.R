# set paths for files
# Meghan Balk 
# balk@battelleecology.org

#### read yaml file ----
dfs <- read_yaml(file = "config.yaml")

meta.df <- read.csv(file = dfs$Image_Metadata[1])

iqm.df <- read.csv(file = dfs$Image_Quality_Metadata[1])

b.df <- read.csv(file = dfs$Burress[1])

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

