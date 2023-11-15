[![DOI](https://zenodo.org/badge/470771551.svg)](https://zenodo.org/badge/latestdoi/470771551)

# Minnow Segmented Traits

We use a segmentation model to extract traits from minnows (Family: Cyprinidae).

This repository serves as a case study of an automated workflow and extraction of morphological traits using machine learning on image data. 

We expand upon work already done by BGNN, including metadata collection by the [Tulane Team](https://bgnn.tulane.edu/) and the [Drexel Team](https://github.com/hdr-bgnn/drexel_metadata) (see [Leipzig et al. 2021](https://link.springer.com/chapter/10.1007/978-3-030-71903-6_1), [Pepper et al. 2021](https://ieeexplore.ieee.org/abstract/document/9651834?casa_token=gzgYa9cfbZAAAAAA:mFhU1Wc4bkBbL066-2Iwsec-eY2u_1h4FfgoDgGMnNqS5NLOTsJ0Jn78GOzU7tbbz4J-sw), and [Narnani et al. 2022](https://www.researchsquare.com/article/rs-1506561/latest.pdf)), and a segmentation model developed by the [Virginia Tech Team](https://github.com/hdr-bgnn/BGNN-trait-segmentation). We developed morphology extraction tools ([Morphology-analysis](https://github.com/hdr-bgnn/Morphology-analysis)) with the help of the Tulane Team. We incorporate these tools into [BGNN_Core_Workflow](https://github.com/hdr-bgnn/BGNN_Core_Workflow).

Finally, with the help of the Duke Team, we create an automated workflow.


![workflow](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/blob/readme-edits/workflow%20use%20case.png)


## Goals

* Create a use case for using an automated workflow
* Show best practices for interacting with other repositories
* Show utility of using a machine learning segmentation model to accelerate trait extraction from images of specimens


## Organization

*Scripts*
- [Data_Manipulation.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Data_Manipulation.R): code for manipulating and merging data files
- [Minnow_Selection_Image_Quality_Metadata.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Minnow_Selection_Image_Quality_Metadata.R): code for image selection
- [Presence_Absence_Analysis.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/Presence_Absence_Analysis.R): code for analyzing machine learning outputs
- [init.R](https://github.com/hdr-bgnn/Minnow_Traits/blob/streamline/Scripts/init.R): code to load functions in [Functions](https://github.com/hdr-bgnn/Minnow_Traits/tree/streamline/Scripts/Functions)

*Files*
- [Previous_Measurements](Files/Previous%20Fish%20Measurements%20-%20Burress%20et%20al.%202016.csv): a file of measurements of minnow traits by  found in the supplemental information. See [Burress.md](Files/Burress.md) for more details.

*Results*
- a folder for the outputs from the workflow
  1. tables of results from analyses
  2. /Figures contains all figures created from analyses

*Config*
- contains the config.yml file
  - the user can change the file inputs or number of images under ```limit_images```

## Inputs

### Data Files

The [Previous_Measurements](Files/Previous%20Fish%20Measurements%20-%20Burress%20et%20al.%202016.csv) file is included in this repository.

The Fish-AIR input files will be downloaded from the [Fish-AIR API](https://fishair.org/).
This requires a [Fish-AIR API key](https://fishair.org/) be added to `Fish_AIR_API_Key` in `config/config.yaml`.
Alternatively you can download the Fish-AIR input files from Dryad and place them in the `Files/Fish-AIR/Tulane` directory.

### Components

The total size of the components are 5.6G (as of 5 May 2023). 

All weights and dependencies for all components of the workflow are uploaded to Hugging Face or Zenodo.

* Metadata by Drexel Team
  - Object detection of fish and rule from fish images
  - [Repository](https://github.com/hdr-bgnn/drexel_metadata)
  - [Model Archive](https://doi.10.57967/hf/0904)
  
* Reformatting of metadata
  - Trim metadata output from Metadata step to only the values necessary for this project
  - [Repository](https://github.com/hdr-bgnn/drexel_metadata_formatter)
  - [Code Archive](https://doi.org/10.5281/zenodo.7987576)

* Crop Image
  - Extract bounding box information from metadata file
  - Resizes and crops fish from image
  - [Repository](https://github.com/hdr-bgnn/Crop_image)
  - [Code Archive](https://doi.org/10.5281/zenodo.7987485)

* Segmentation Model by Virginia Tech Team
  - Segments fish traits from fish images
  - [Repository](https://github.com/hdr-bgnn/BGNN-trait-segmentation)
  - [Model Archive](https://doi.org/10.57967/hf/0832)

* Morphology analysis by Tulane Team and Battelle Team
  - Tool to calculate presence of traits
  - [Repository](https://github.com/hdr-bgnn/Morphology-analysis)
  - [Code Archive](https://doi.org/10.5281/zenodo.7987697)

* Machine Learning Workflow by Battelle Team and Duke Team
  - Calls all the above containers
  - [Repository](https://github.com/hdr-bgnn/BGNN_Core_Workflow)
  - [Code Archive](https://doi.org/10.5281/zenodo.7987705)


### Images

The fish images are from the Great Lakes Invasives Network [(GLIN)](https://glin.com/) and stored on [Fish-AIR](https://fishair.org/). 
We are using images specifically from the [Illinois Natural History Survey](https://inhs.illinois.edu/) [(INHS images)](http://www.tubri.org/HDR/INHS/).


#### Image Selection
    
R code (Minnow_Selection_Image_Quality_Metadata.R) was used to filter out high quality, minnow images using the IQM and IM metadata files.

All image metadata files are downloaded from [Fish-AIR](https://fishair.org/) and the version used is stored on the OSC data commons under the Fish Traits dataverse. The metadata files have been generated using the [Tulane worflow](https://bgnn.tulane.edu/).

Criteria for selection of an image was based on findings from [Pepper et al. 2021](https://ieeexplore.ieee.org/abstract/document/9651834?casa_token=gzgYa9cfbZAAAAAA:mFhU1Wc4bkBbL066-2Iwsec-eY2u_1h4FfgoDgGMnNqS5NLOTsJ0Jn78GOzU7tbbz4J-sw).

Criteria chosen:

* family == "Cyprinidae"
* specimenView == "left"
* specimenCurved == "straight"
* allPartsVisible == "True"
* partsOverlapping == "True"
* partsFolded == "False"
* uniformBackground == "True"
* partsMissing == "False"
* brightness == "normal"
* onFocus == "True"
* colorIssues == "none"
* containsScaleBar == "True"
* from either INHS or UWZM institutions


### Analysis

See more details in [Morphology-analysis](https://github.com/hdr-bgnn/Morphology-analysis).

Each segmented image has the following traits: trunk, head, eye, dorsal fin, caudal fin, anal fin, pelvic fin, and pectoral fin. For each segmented trait, there may be more than one "blob", or group of pixels identifying a trait. We created a matrix of <a href="https://github.com/hdr-bgnn/minnowTraits/blob/main/Files/presence.absence.matrix.csv"> presence.absence.matrix.csv</a>.

For each trait, we counted the number of "blobs" and the percentage of the largest blob as a proportion of all blobs for a trait.

All intermediate tables will be saved in the folder "Results".


#### Figures

We created a heat map to show the success of the segmentation to detect traits from the images.

Figures are in the folder "Results".


## Running the Workflow
Instructions are provided for running the workflow on a single computer or a [SLURM cluster](https://slurm.schedmd.com/).

### Software Requirements
To run the workflow [conda](https://docs.conda.io/projects/conda/en/stable/) and [singularity (aka apptainer)](https://apptainer.org/) must to be installed.

### Hardware Requirements
Minimally the workflow requires 1 CPU, 5 GB memory, and 20 GB disk space.
A Linux machine is required for this workflow to provide Singularity containerization.

### Install Workflow Runner
To run the workflow [snakemake](https://snakemake.readthedocs.io/en/stable/index.html) with [mamba](https://mamba.readthedocs.io/en/latest/) must be installed.
To handle this we create a new conda environment named "snakemake".

If you are running the workflow on a cluster that provides a conda environment module you should load that module
(eg. `module load miniconda3`).

Run the following command to create a conda environment named "snakemake" with the required workflow dependencies.
```console
conda create -c conda-forge -c bioconda -n snakemake snakemake mamba
```
Enter "Y" when prompted to install snakemake and mamba.

If you loaded an environment module you should unload it (eg. `module purge`).

See the [official instructions for installing snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) for more options.

### Limit images

In the [config/config.yaml](config/config.yaml) file, the user can limit the number of images for a test run by change the integer under ```limit_images```, or run them all by entering ```""```.

### Run snakemake

Run the following commands to activate the conda environment and run the workflow:
```console
source activate snakemake
snakemake --jobs 1 --use-singularity --use-conda
```
The `--jobs` argument specifies how many processes the snakemake can run at a time.

### Run snakemake on a SLURM Cluster
Running the workflow on a SLURM cluster enables scaling beyond a single machine.
The [run-workflow.sh](run-workflow.sh) sbatch script is provided to run the workflow using sbatch and will process up to 20 jobs simultaneously.

If your SLURM cluster provides a conda environment module you should load that module before running the next step(eg. `module load miniconda3`).

Run the following commmand to activate the snakemake conda environment:
```console
source activate snakemake
```

Running on the workflow in the background:
```console
sbatch run-workflow.sh
```
Then you can monitor the job progress as you would with any SLURM background job.
Some SLURM clusters require providing `sbatch` a SLURM account name via the `--account` command line argument.

See the [Run-on-OSC wiki article](https://github.com/hdr-bgnn/Minnow_Segmented_Traits/wiki/Run-on-OSC) for the commands used to run the workflow on OSC.
