# import dependencies for R
# Meghan Balk 
# balk@battelleecology.org
source("paths.R")

#create Library folder
lib.path <- 'Library'
dir.create(path = lib.path)

remotes::install_version("rjson",
                         version = "0.2.21",
                         upgrade = "never",
                         lib = lib.path)

remotes::install_version("reshape2",
                         version = "1.4.4",
                         upgrade = "never",
                         lib = lib.path)
