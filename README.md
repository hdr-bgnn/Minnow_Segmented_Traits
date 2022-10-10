# minnowTraits
We use a segmentation model to extract morphological traits from minnows (Family: Cyprinidae). We expand upon work already done by BGNN, including metadata collection (by the <a href="https://bgnn.tulane.edu/">Tulane Team</a> and Drexel Team, see <a href="https://link.springer.com/chapter/10.1007/978-3-030-71903-6_1">Leipzig et al. 2021</a>, <a href="https://ieeexplore.ieee.org/abstract/document/9651834?casa_token=gzgYa9cfbZAAAAAA:mFhU1Wc4bkBbL066-2Iwsec-eY2u_1h4FfgoDgGMnNqS5NLOTsJ0Jn78GOzU7tbbz4J-sw">Pepper et al. 2021</a>, and <a href="https://www.researchsquare.com/article/rs-1506561/latest.pdf">Narnani et al. 2022</a>) and a segementation model developed by the Virginia Tech Team. We incorporate these tools into the BGNN_Snakemake, develop new morphology extraction tools with the help of the Tulane Team, and present a case study.

![minnowTraits_workflow](https://github.com/hdr-bgnn/minnowTraits/blob/main/minnowTraits_workflow.png)

## Goals

* Highlight <a href="https://github.com/hdr-bgnn/BGNN_Snakemake">BGNN_Snakemake workflow</a>
* Show utility of using a machine learning segmentation model to accelerate trait extraction from images of specimens without sacrificing accuracy.

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

Selecting only the species in Burress et al. 2017, We are left with 446 images and 8 species
* <i>Notropis volcucellus</i> (145)
* <i>Notropis texanus</i> (97)
* <i>Notropis leuciodus</i> (71)
* <i>Notropis rubellus</i> (46)
* <i>Notropis photogenis</i> (33)
* <i>Notropis baileyi</i> (16)
* <i>Notropis ammophilus</i> (15)
* <i>Notropis stilbius</i> (23)

### Analyses on segmented images

*This section will describe the analyses*

## Minnow trait selection

These images below contain all the traits discussed by our team. This section outlines which traits we are focusing on for this study. We have created descriptions of the traits for <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/MinnowMeasurements%20(trimmed%2028Jun2022).csv">measurements</a> and <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/MinnowLandmarks%20(trimmed%2028Jun2022).csv">landmarks</a>.

### Measurements
![Minnow Measurements](https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow_Measurements_Burress_et_al_2017.png)

All traits except head depth through the midline of the eye (HH) were done using both landmarks (with suffix "_lm") and a bounding box (with suffix "_bbox"). See <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow_Measurements_Burress_et_al_2017.csv">Minnow_Measurements_Burress_et_al_2017.csv</a> for descriptions of the measurements.

**Standard length (SL)**: edge of head to beginning of caudal fin along nose line[ <a href="https://www.sciencedirect.com/science/article/abs/pii/S1055790312000668">Nagel & Simons 2012</a>; <a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2017</a>].

**Head length (HL)**: tip of snout to posterior tip of opercle; anterior-posterior length of head segmentation [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2017</a>].

**Eye diameter (ED)**: anterior-posterior length of eye segmentation [<a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2017</a>].

**Head height (HH)**: vertical distance of head dorso-ventrally through the center of the eye [called head depth in <a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2017</a>].

**Preorbital depth (pOD)**: anterior tip of head to anterior eye [called snout length (SnL) in <a href="https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024">Burress et al. 2017</a>].

### Landmarks
**Fin and eye positions**: a series of landmarks [<a href="https://www.biotaxa.org/Zootaxa/article/view/zootaxa.3586.1.3/44599">Armbruster 2012</a>]; we can use the segmentation to our advantage:

![Minnow Landmarks](https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow_Landmarks_Burress_et_al_2017.png)

See <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Traits/Minnow_Landmarks_Burress_et_al_2017.csv">Minnow_Landmarks_Burress_et_al_2017.csv</a> for descriptions of the position of the landmarks.

1. Anterior portion of head
6. Posterior caudal fin connection with trunk
12. Posterior part of head segmentation
14. posterior of eye
15. anterior of eye
18. centroid of eye

### Trait extraction
More information on trait extraction can be found on the <a href="https://github.com/hdr-bgnn/Morphology-analysis">Morphological Analysis repository</a>

## Running the Workflow
This workflow requires R, conda, and singularity to run.

### Installing snakemake
To run the workflow we use snakemake.
See the [official instructions for installing snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

To install snakemake on the OSC cluster run:
```
module load miniconda3
conda create -n snakemake -c bioconda -c conda-forge snakemake -y
```
where -n designates the name, "snakemake", -c designates the channel(s), "bioconda" and "conda-forge".

To check that the environment was made:
```
conda info -e
```

### Installing R packages
The R packages required by the pipeline must be installed into the `Library` directory.
This can be accomplished by running `Rscript dependencies.R`.
On the OSC cluster this can be done like so:
```
mkdir Library
module load cmake #defaukts to version on node
module load R/4.2.1-gnu11.2
Rscript dependencies.R 
```

### Dataverse configuration
To download the unpublished input files from our Dataverse instance requires
supplying the URL to the instance and a Dataverse API Token.
The URL and API Token need to be placed into a config file stored in your home
directory name ".dataverse".

To find your token visit [datacommons.tdai.osu.edu]( https://datacommons.tdai.osu.edu/),
after logging in click your name in the top right corner, click API Token.
You should see a screen for managing your API Token.

Then run the following command to create your config file:
```
singularity run docker://ghcr.io/imageomics/dataverse-access:0.0.3 dva setup
```
This command will download the dva container and create your `~/.dataverse` config file.
You will see two prompts. For the `URL` prompt enter `https://datacommons.tdai.osu.edu/`.
For `API Token` prompt enter your API token.
```
Enter Dataverse URL: https://datacommons.tdai.osu.edu/
Enter your Dataverse API Token: <yourtoken>
```


### Running snakemake

Activate snakemake:
```
source activate snakemake
```

To run on a local computer:
After activating R and snakemake the pipeline can be run using `snakemake --cores 1`.

To run on the OSC cluster: 
```
sbatch run-workflow.sh
```

To check the status of the job:
```
squeuqe -u $USER
```
