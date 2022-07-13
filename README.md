# minnowTraits
Using machine learning segmentation model to accelerate trait extraction from images.

## Folder Organization

*Scripts*
- code used for image selection

*Files*
- contains files used in the code

*OSC*
- files used to upload to the OSC for the <a href="https://github.com/hdr-bgnn/BGNN_Snakemake">Snakemake workflow</a>

*PDFs*
- papers relevant to the trait selection

*Traits*
- csv for trait selection and definition
- images to describe trait selection

*Prelim Results*
- contains plots from preliminary statistics

## Minnow image selection

The fish images are from the Great Lakes Invasives Network (<a href="https://glin.com/">GLIN</a>) and stored on the Tulane server. We're using images specifically from the <a href="https://inhs.illinois.edu/">Illinois Natural History Survey</a> (<a href="http://www.tubri.org/HDR/INHS/">INHS images</a>) and from the <a href="https://uwzm.integrativebiology.wisc.edu/">University of Wisconsin Zoological Museum</a> (<a href="http://www.tubri.org/HDR/UWZM/">UWZM images</a>).

### Selection of images to run through the workflow

**This section describes the creation of minnow.filtered.from.imagequalitymetadata_7Jun2022.csv using minnowSelectionImageQualityMetadata.R**    
R code (Minnows.R) was used to filter out high quality, minnow images using:

- Image_Quality_Metadata_v1_202111206_151204.csv : list of fish, url species information
- Image_Metadata_v1_20211206_151152.csv. : List of quality metadata including manually extracted information on the quality of the images and their content.

Those two lists are download from <a href="https://bgnn.tulane.edu/hdrweb/hdr/imagemetadata/">Tulane sever</a>. The lists have been generated using the <a href="https://bgnn.tulane.edu/">Tulane worflow</a>.

List of criteria chosen :

* family == "Cyprinidae"
* specimen_viewing == "left"
* straight_curved == "straight"
* brightness == "normal"
* color_issues == "none"
* has_ruler == "True"
* if_overlapping == "False"
* if_focus == "True"
* if_missing_parts == "False"
* if_parts_visible == "True"
* fins_folded_oddly == "False"
* from either INHS or UWZM institutions
    - Note: there currently is not any image quality metadata for UWZM, so this institution is omitted
* no duplicated original_file_names
* removed any images that had an empty file or where the URL did not resolve
* at least 10 images per species

**The resulting dataset of 41 species and 6300 images.**

We ignored if_background_uniform == "True" because it reduced the sample size too much.

The resulting dataset was then merged with the <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Files/Image_Quality_Metadata_v1_20211206_151204.csv">Image_Metadata_v1_20211206_151152.csv</a>.

### Selection of which segmented images to analyze

Each segmented image has the following traits: trunk, head, eye, dorsal fin, caudal fin, anal fin, pelvic fin, and pectoral fin. For each segmented trait, there may be more than one "blob", or group of pixels identifying a trait. We created a matrix of <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Files/presence.absence.matrix.csv"> presence.absence.matrix.csv</a>.

We removed images where a trait was missing. That removed only 40 images.

For each trait, we counted the number of blobs and the percentage of the largest blob. We analyzed this matrix using the <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Scripts/selectionCriteraSegmentedImages.R">selectionCriteriaSegmentedImages.R</a> in Scripts and results can be found in the folder Preliminary Results.

Based on these results, we chose a criteria of blob size of 95% (that is, the biggest blob is 95% of the sum of all the blobs for a trait).

This results in 39 species and 4,663 images.

### Analyses on segmented images

*This section will describe the analyses*

## Minnow trait selection

These images below contain all the traits discussed by our team. This section outlines which traits we are focusing on for this study. We have created descriptions of the traits for <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/MinnowMeasurements%20(trimmed%2028Jun2022).csv">measurements</a> and <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/MinnowLandmarks%20(trimmed%2028Jun2022).csv">landmarks</a>.

### Measurements
![Minnow Measurements](https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow%20Length%20Traits%20(trimmed%2012Jul2022).png)

**Standard length (SL)**: edge of head to beginning of caudal fin along nose line, done in <a href="https://www.sciencedirect.com/science/article/abs/pii/S1055790312000668">Nagel & Simons 2012</a> where they showed DNA aligned with morphological data for <i>Nocomis</i>; also done in <a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2016</a> looking at benthic-pelagic transition in NA minnows.

**Head length (HL)**: tip of snout to posterior tip of opercle; anterior-posterior length of head segmentation [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2016</a>].

**Eye diameter (ED)**: anterior-posterior length of eye segmentation [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2016</a>].

**Head depth (HD)**: vertical distance of head dorso-ventrally through the center of the eye [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2016</a>].

**Snout length or preorbital depth (pOD)**: anterior tip of head to anterior eye [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2016</a>].

### Landmarks
**Fin and eye positions**: a series of landmarks [<a href="https://www.biotaxa.org/Zootaxa/article/view/zootaxa.3586.1.3/44599">Armbruster 2012</a>]; we can use the segmentation to our advantage:

![Minnow Landmarks](https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow%20Landmarks%20(1-18).png)

#### We are only focusing on the following landmarks for this project:

1. Anterior portion of head
6. Posterior caudal fin connection with trunk
12. Posterior part of head segmentation
14. posterior of eye
15. anterior of eye
18. centroid of eye
