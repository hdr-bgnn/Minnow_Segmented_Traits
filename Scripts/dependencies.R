################################################################################
#' @title Installs dependencies for scripts in minnowTraits/Scripts. 

#' @author
#' Meghan A. Balk \email{balk@battelleecology.org} \cr

#' @description Installs dependencies needed for the .R files in 
# minnowTraits/Scripts. The packages used in these scripts currently use the  
# following versions: (version determined using packageVersion())

# changelog and author contributions
#   Meghan Balk (2022-07-13)
#     original creation

# Meghan Balk (2022-08-08)
#   adding more packages
#   organizing package type
################################################################################

install.packages("devtools")

#turn json files to R objects
devtools::install_version("rjson", version = "0.2.21")

#data manipulation packages
devtools::install_version("stringr", version = "1.4.0")
devtools::install_version("tidyr", version = "1.2.0")
devtools::install_version("reshape2", version = "1.4.4")
devtools::install_version("dplyr", version = "1.0.8")

#statistic packages
devtools::install_version("moments", version = "0.14.1")

#plotting packages
devtools::install_version("ggplot2", version = "3.3.5")
devtools::install_version("RColorBrewer", version = "1.1.2")
devtools::install_version("ggpubr", version = "0.4.0")
