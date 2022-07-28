# Run Step by step the analysis

## 1- Introduction

This Readme file will describe step by step how to run each section of the analysis on OSC (supercomputer system) 
Each step is defined by a rule which contained in a Snakefile named : Snake_"step_name".

step_name :

 + download : dowload the image
 + metadata : generate metadata
 + crop : crop the fish
 + seg : segment the fish
 + morph : calculate the morphology analysis

#### To start

Clone minnowTraits to the OSC folder

Set up snake environment

#### To update

Each snake file is associated with a container. To update the container, open the snake file and change the docker version.

#### To run

cd into folder with the slurm and snakemake files.

## 2- Run Download
This step has its own SLURM script (SLURM_Snake_dowload) because of the input <INPUT_CSV_LIST>

+ <INPUT_CSV_LIST> : List of name and url should comply with [this description]()
+ <number_of_core> : number of core allocated
+ Create a directory "My_minnows_project"
+ /fs/ess/<project_name>/My_minnows_project : Location where the data are or will be.

```
sbatch SLURM_Snake_download Snake_download /fs/ess/<project_name>/My_minnows_project <number_of_core>  <INPUT_CSV_LIST> 
```
This should create a folder Images containing the result from "Download"
## 3 - Run Metadata

In /fs/ess/<project_name>/My_minnows_project, Images folder should be present with the Fish images (generate by 2- Run Download)

```
sbatch SLURM_Snake_generic Snake_metadata /fs/ess/<project_name>/My_minnows_project <number_of_core>  
```
his should create a folder Metadata containing the result from "Metadata"

## 3 - Run Crop

In /fs/ess/<project_name>/My_minnows_project, Metadata folder should be present with the Fish images (generate by 2- Run Download)

```
sbatch SLURM_Snake_generic Snake_crop /fs/ess/<project_name>/My_minnows_project <number_of_core>  
```
This should create a folder Metadata containing the result from "Crop"

## 4 - Run Segmentation

In /fs/ess/<project_name>/My_minnows_project, Cropped folder should be present with the Fish images (generate by 2- Run Download)

```
sbatch SLURM_Snake_generic Snake_seg /fs/ess/<project_name>/My_minnows_project <number_of_core>  
```
This should create a folder Segmented containing the result from "Segmentation

## 5 - Run Morphology

In /fs/ess/<project_name>/My_minnows_project, Morphology folder should be present with the Fish images (generate by 4- Run Segmentation)

```
sbatch SLURM_Snake_generic Snake_morph /fs/ess/<project_name>/My_minnows_project <number_of_core>  
```
This should create a folder Morphology containing the result from "Morphology"




