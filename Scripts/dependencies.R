################################################################################
#' @title Installs dependencies for scripts in minnowTraits/Scripts. 

#' @author
#' Meghan A. Balk \email{balk@battelleecology.org} \cr

#' @description Installs dependencies needed for the .R files in 
# minnowTraits/Scripts. The packages used in these scripts currently use the  
# following versions: (version determined using packageVersion())
# -devtools 2.4.3
# -rjson 0.2.21
# -tidyr 1.2.0
# -dplyr 1.0.8
# -ggplot2 3.3.5
# -RColorBrewer 1.1.2
# -stringr 1.4.0
# -reshape2 1.4.4

# changelog and author contributions
#   Meghan Balk (2022-07-13)
#     original creation
################################################################################

install.packages("devtools")

devtools::install_version("rjson", version="0.2.21")
devtools::install_version("tidyr", version="1.2.0")
devtools::install_version("dplyr", version="1.0.8")
devtools::install_version("ggplot2", version="3.3.5")
devtools::install_version("RColorBrewer", version="1.1.2")
devtools::install_version("stringr", version="1.4.0")
