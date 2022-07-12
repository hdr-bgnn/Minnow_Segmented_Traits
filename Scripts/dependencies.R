#file to install all the dependencies needed for the R code in /Scripts
#Meghan A. Balk
#balk@battelleecology.org

##versions: (using packageVersion())
#devtools 2.4.3
#rjson 0.2.21
#tidyr 1.2.0
#dplyr 1.0.8
#ggplot2 3.3.5
#RColorBrewer 1.1.2
#stringr 1.4.0
#reshape2 1.4.4

install.packages(c("devtools", 
                   "rjson", 
                   "tidyr", 
                   "dplyr", 
                   "ggplot2", 
                   "RColorBrewer", 
                   "stringr",
                   "reshape2"))
