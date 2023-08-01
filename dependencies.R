# import dependencies for R

source("paths.R")

#create Library folder
dir.create(path = '/Library')

## create new library for versions
.libPaths(c(.libPaths(), file.path(getwd(), library))) #creates place to store package versions
.libPaths() #make sure it was created
lib.path <- file.path(tail(.libPaths(), 1)) #last path created

## install all necessary packages
options(install.packages.check.source = "no", repos = "https://cloud.r-project.org")

install.packages("remotes",
                 dependencies = TRUE)
library(remotes)

#turn json files to R objects
install.packages("rjson")
                #         version = "0.2.21",
                #         upgrade = "never",

#read yaml files
remotes::install_version("yaml",
                         version = "2.3.5",
                         upgrade = "never")

#read xml files
remotes::install_version("XML",
                         version = "3.99-0.11",
                         upgrade = "never")

#data manipulation packages
remotes::install_version("stringr",
                         version = "1.4.0",
                         upgrade = "never")
remotes::install_version("tidyr",
                         version = "1.2.0",
                         upgrade = "never")
remotes::install_version("reshape2",
                         version = "1.4.4",
                         upgrade = "never")
remotes::install_version("dplyr",
                         version = "1.0.8",
                         upgrade = "never")

#statistic packages
remotes::install_version("moments",
                         version = "0.14.1",
                         upgrade = "never")

#plotting packages
remotes::install_version("ggplot2",
                         version = "3.3.5",
                         upgrade = "never")
remotes::install_version("RColorBrewer",
                         version = "1.1.2",
                         upgrade = "never")
remotes::install_version("ggpubr",
                         version = "0.4.0",
                         upgrade = "never")

##load everything
p <- c("rjson", "XML",
       "stringr", "tidyr", "reshape2", "dplyr",
       "moments",
       "ggplot2", "RColorBrewer", "ggpubr")
lapply(p, 
        require, character.only = TRUE)

