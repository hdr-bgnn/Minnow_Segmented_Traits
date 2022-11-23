# set paths for files
# Meghan Balk
# balk@battelleecology.org

#put directory to cloned repo
config_file <- file.path("config", "config.yaml")

library <- "Library" # library for version of R packages
scripts <- "Scripts" # folder with scripts
functions <- file.path(scripts, "Functions") # folder with utility scripts
files <- "Files" # folder with files to read into scripts
results <- "Results" # folder to store outputs of scripts
figures <- file.path("Results", "Figures")
workflow <- file.path("Workflow")
presence <- file.path("segmentation", "Morphology", "Presence") # this data is produced by the BGNN_Snakemake workflow
measure <- file.path("segmentation", "Morphology", "Measure") # this data is produced by the BGNN_Snakemake workflow
