# set paths for files
# Meghan Balk 
# balk@battelleecology.org

#put directory to cloned repo
library <- "Library" # library for version of R packages
scripts <- "Scripts" # folder with scripts
files <- "Files" # folder with files to read into scripts
results <- "Results" # folder to store outputs of scripts
figures <- file.path("Results", "Figures")
presence <- file.path("Snakemake", "Morphology", "Presence") #this would be whatever snakemake produces. what folder would this be in?
measure <- file.path("Snakemake", "Morphology", "Measure") #this would be whatever snakemake produces. what folder would this be in?