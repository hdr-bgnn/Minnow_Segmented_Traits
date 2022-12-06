# Minnow Segmented Traits

We use a segmentation model to extract traits from minnows (Family: Cyprinidae).

This repository serves as a case study of an automated workflow and extraction of morphological traits using machine learning on image data. 

We expand upon work already done by BGNN, including metadata collection by the [Tulane Team](https://bgnn.tulane.edu/) and the [Drexel Team](https://github.com/hdr-bgnn/drexel_metadata_formatter) (see [Leipzig et al. 2021](https://link.springer.com/chapter/10.1007/978-3-030-71903-6_1), [Pepper et al. 2021](https://ieeexplore.ieee.org/abstract/document/9651834?casa_token=gzgYa9cfbZAAAAAA:mFhU1Wc4bkBbL066-2Iwsec-eY2u_1h4FfgoDgGMnNqS5NLOTsJ0Jn78GOzU7tbbz4J-sw), and [Narnani et al. 2022](https://www.researchsquare.com/article/rs-1506561/latest.pdf)), and a segmentation model developed by the [Virginia Tech Team](https://github.com/hdr-bgnn/BGNN-trait-segmentation). We developed morphology extraction tools ([Morphology-analysis](https://github.com/hdr-bgnn/Morphology-analysis)) with the help of the Tulane Team. We incorporate these tools into [BGNN_Snakemake](https://github.com/hdr-bgnn/BGNN_Snakemake).

Finally, with the help of the Duke Team, we create an automated workflow.


![workflow](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/blob/streamline/Files/workflow%20use%20case.png)


## Goals

* Create a template for creating an automated workflow
* Show best practices for interacting with other repositories
* Show utility of using a machine learning segmentation model to accelerate trait extraction from images of specimens


## Organization

*Scripts*
- [Data_Manipulation.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Data_Manipulation.R):code for manipulating and merging data files
- [Minnow_Selection_Image_Quality_Metadata.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Minnow_Selection_Image_Quality_Metadata.R): code for image selection
- [Presence_Absence_Analysis.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Presence_Absence_Analysis.R): code for analyzing machine learning outputs
- [init.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/init.R): code to load functions in [Functions](https://github.com/hdr-bgnn/Minnow_Traits/tree/streamline/Scripts/Functions)

*Files*
- [Previous_Measurements](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/blob/streamline/Files/Previoius_Measurements.xlsx): a file of measurements of minnow traits by  found in the supplemental information
- [Workflow](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/blob/streamline/Files/workflow%20use%20case.png): a schematic of the automated workflow for this project

*Library*
- a folder to hold the R package dependencies

*Results*
- a folder for the outputs from the workflow
  1. tables of results from analyses
  2. /Figures contains all figures created from analyses


## Inputs

### Data Files

All input files are stored in the [Fish Traits](https://covid-commons.osu.edu/dataverse/fish-traits) dataverse hosted by OSU.

- [Minnow trait measurements](https://covid-commons.osu.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/KLN3CS&version=DRAFT) from [Burress et al. 2017](https://onlinelibrary.wiley.com/doi/full/10.1111/jeb.13024) [Supplemental Information](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/blob/streamline/Files/jeb13024-sup-0001-supinfo.docx).
- [Image Quality Metadata v1_20211206_151204 (IQM)](https://covid-commons.osu.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/ZIFDTJ&version=DRAFT): metadata about the image quality (downloaded from the Tulane API)
- [Image Metadata v1_20211206_151152 (IM)](https://covid-commons.osu.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/QOHJGD&version=DRAFT): metadata about the specimen image (downloaded from the Tulane API)

### Components

All weights and dependencies for all components of the workflow are stored in the [Fish Traits](https://covid-commons.osu.edu/dataverse/fish-traits) dataverse hosted by OSU.

* Metadata by Drexel Team
  - Object detection of fish and rule from fish images
  - [Repository](https://github.com/hdr-bgnn/drexel_metadata_formatter)
  - [Model Weights](https://covid-commons.osu.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/MMX6FY&version=DRAFT)

* Segmentation Model by Virginia Tech Team
  - Segments fish traits from fish images
  - [Repository](https://github.com/hdr-bgnn/BGNN-trait-segmentation)
  - [Pretrained Model Weights](https://covid-commons.osu.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/CGWDW4)
  - [Trained Model Weights](BGNN-trait-segmentation)

* Morphology analysis by Tulane Team and Battelle Team
  - Tool to calculate presence of traits
  - [Repository](https://github.com/hdr-bgnn/Morphology-analysis)

* Machine Learning Workflow by Battelle Team and Duke Team
  - Calls Metadata container and Segmentation container
  - [Repository](https://github.com/hdr-bgnn/BGNN_Snakemake)


### Images

The fish images are from the Great Lakes Invasives Network [(GLIN)](https://glin.com/) and stored on the Tulane API (LINK). 
We are using images specifically from the [Illinois Natural History Survey](https://inhs.illinois.edu/) [(INHS images)](http://www.tubri.org/HDR/INHS/).


#### Image Selection
    
R code (Minnow_Selection_Image_Quality_Metadata.R) was used to filter out high quality, minnow images using the IQM and IM metadata files.

IQM and IM are both downloaded from the Tulane API and the version used is stored on the OSC data commons under the Fish Traits dataverse. The metadata files have been generated using the [Tulane worflow](https://bgnn.tulane.edu/).

Criteria for selection of an image was based on findings from [Pepper et al. 2021](https://ieeexplore.ieee.org/abstract/document/9651834?casa_token=gzgYa9cfbZAAAAAA:mFhU1Wc4bkBbL066-2Iwsec-eY2u_1h4FfgoDgGMnNqS5NLOTsJ0Jn78GOzU7tbbz4J-sw).

Criteria chosen:

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


### Analysis

See more details in [Morphology-analysis](https://github.com/hdr-bgnn/Morphology-analysis).

Each segmented image has the following traits: trunk, head, eye, dorsal fin, caudal fin, anal fin, pelvic fin, and pectoral fin. For each segmented trait, there may be more than one "blob", or group of pixels identifying a trait. We created a matrix of <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Files/presence.absence.matrix.csv"> presence.absence.matrix.csv</a>.

We removed images where a trait and the scale were missing. That removed X images.

For each trait, we counted the number of "blobs" and the percentage of the largest blob as a proportion of all blobs for a trait.

All intermediate tables are saved in the folder "Results".

Selecting only the species in Burress et al. 2017, We are left with 446 images and 8 species
* <i>Notropis volcucellus</i> (X)
* <i>Notropis texanus</i> (X)
* <i>Notropis leuciodus</i> (X)
* <i>Notropis rubellus</i> (X)
* <i>Notropis photogenis</i> (X)
* <i>Notropis baileyi</i> (X)
* <i>Notropis ammophilus</i> (X)
* <i>Notropis stilbius</i> (X)


#### Figures

We created a heat map to show the success of the segmentation to detect traits from the images.

Figures are in the folder "Results".

## Running the Workflow

This workflow requires R, conda, and docker to run.

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

The R packages required by the pipeline must be installed into the `Library` directory that is created.
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
