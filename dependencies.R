# import dependencies for R
# Meghan Balk 
# balk@battelleecology.org
source("paths.R")

## create new library for versions
.libPaths(c(.libPaths(), file.path(getwd(), library))) #creates place to store package versions
.libPaths() #make sure it was created
lib.path <- file.path(tail(.libPaths(), 1)) #last path created

## install all necessary packages
options(install.packages.check.source = "yes", repos = "https://cloud.r-project.org")

install.packages("remotes",
                 dependencies = TRUE,
                 lib = lib.path) #click "No" on pop up
library(remotes,
        lib.loc = lib.path)

#turn json files to R objects
remotes::install_version("rjson",
                         version = "0.2.21",
                         upgrade = "never",
                         lib = lib.path)

#read yaml files
remotes::install_version("yaml",
                         version = "2.3.5",
                         upgrade = "never",
                         lib = lib.path)

#data manipulation packages
remotes::install_version("stringr",
                         version = "1.4.0",
                         upgrade = "never",
                         lib = lib.path)
remotes::install_version("tidyr",
                         version = "1.2.0",
                         upgrade = "never",
                         lib = lib.path)
remotes::install_version("reshape2",
                         version = "1.4.4",
                         upgrade = "never",
                         lib = lib.path)
remotes::install_version("dplyr",
                         version = "1.0.8",
                         upgrade = "never",
                         lib = lib.path)

#statistic packages
remotes::install_version("moments",
                         version = "0.14.1",
                         upgrade = "never",
                         lib = lib.path)

#plotting packages
remotes::install_version("ggplot2",
                         version = "3.3.5",
                         upgrade = "never",
                         lib = lib.path)
remotes::install_version("RColorBrewer",
                         version = "1.1.2",
                         upgrade = "never",
                         lib = lib.path)
remotes::install_version("ggpubr",
                         version = "0.4.0",
                         upgrade = "never",
                         lib = lib.path)

##load everything
p <- c("rjson",
       "stringr", "tidyr", "reshape2", "dplyr",
       "moments",
       "ggplot2", "RColorBrewer", "ggpubr")
lapply(p, 
        require, character.only = TRUE, lib.loc = lib.path)

