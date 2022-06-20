# Data Processing

- combined with <a href = "https://github.com/hdr-bgnn/minnowTraits/blob/main/Files/Image_Metadata_v1_20211206_151152.csv"> Image Metadata</a>
- removed adipose fin presence/absence because minnows don't have that fins

# Preliminary Results

- only 40 images have at least one missing trait (6260 images remain)
- 5026 images have 85% blobs for each trait
  - of those, only two species have less than 10 images; 39 species remain
  - this results in 5009 images for species with at least 10 images
- Created heat maps of:
  - average blob size of the largest blob of images within a species
  - standard deviation of blob sizes of images within a species
  - distribution of sampling per species
