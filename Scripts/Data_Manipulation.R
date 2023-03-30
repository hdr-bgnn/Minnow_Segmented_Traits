# set paths for files
# Meghan Balk
# balk@battelleecology.org

source("Scripts/fish-air.R")

#### read yaml file ----
dfs <- yaml::read_yaml(file = config_file)
checkpoint.limit_image <- dfs$limit_images

meta.df.term_to_colname <- list(
  "http://purl.org/dc/terms/identifier" = "ARKID",
  "http://rs.tdwg.org/ac/terms/accessURI" = "accessURI",
  "http://rs.tdwg.org/dwc/terms/scientificName" = "scientificName",
  "http://rs.tdwg.org/dwc/terms/genus" = "genus",
  "http://rs.tdwg.org/dwc/terms/family" = "family",
  "http://rs.tdwg.org/dwc/terms/ownerInstitutionCode" = "imageOwnerInstitutionCode"
)
meta.df <- fa_read_csv(
  csv_path = dfs$Image_Metadata,
  meta_xml_path = dfs$File_Metadata,
  term_to_colname = meta.df.term_to_colname)

iqm.df.term_to_colname <- list(
  "http://purl.org/dc/terms/identifier" = "ARKID",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_specimenView" = "specimenView",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_specimenCurved" = "specimenCurved",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_brightness" = "brightness",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_colorIssue" = "colorIssue",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_containsScaleBar"= "containsScaleBar", # formerly contains_ruler
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_partsOverlapping" = "partsOverlapping",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_onFocus" = "onFocus",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_partsMissing" = "partsMissing",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_allPartsVisible" = "allPartsVisible",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_partsFolded" = "partsFolded",
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks_uniformBackground" = "uniformBackground",
  "http://rs.tdwg.org/dwc/terms/ownerInstitutionCode" = "ownerInstitutionCode",
  "http://rs.tdwg.org/dwc/terms/organismQuantity" = "organismQuantity"
)
iqm.df <- fa_read_csv(
  csv_path = dfs$Image_Quality_Metadata,
  meta_xml_path = dfs$File_Metadata,
  term_to_colname = iqm.df.term_to_colname)

# Add scientificName, genus, family, and ownerInstitutionCode to iqm.df from meta.df
# Note ownerInstitutionCode in meta.df has a different value/meaning from iqm.df
iqm.df <- merge(iqm.df, meta.df[,c("ARKID", "scientificName", "genus", "family", "imageOwnerInstitutionCode")], by="ARKID", all.x = TRUE)


b.df <- read.csv(file = dfs$Burress)

# Output file paths
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
# meta.data is metadata about the images
# iqm is metadata about image quality

## burress previous measurements
# measurements from Burress et al. 2017 (see PDFs/Burress et al. 2017  Ecological diversification associated with the benthic‐to‐pelagic transition supinfo.docx)
b.df <- read.csv(file = file.path(files, "Previous Fish Measurements - Burress et al. 2016.csv"),
                 head = TRUE)

# create list of species
b.sp <- unique(b.df$Species)

# label measurements with "b_" to show they're from Burress et al. 2017

names(b.df)[2:10] <- paste0("b.",names(b.df)[2:10])
