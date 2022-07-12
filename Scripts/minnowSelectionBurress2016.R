# selection of minnow images based on previous studies (Burress et al. 2016)
# Meghan Balk 
# balk@battelleecology.org

library(stringr)
library(tidyr)
library(dplyr)

minnow.meta <- read.csv("minnow.filtered.from.imagequalitymetadata_17Jun2022.csv",
                        header = TRUE)

burress.df <- read.csv("Previous Fish Measurements - Burress et al. 2016.csv", 
                       header = TRUE)

minnow.trim <- minnow.meta[minnow.meta$scientific_name.x %in% burress.df$Species,]
nrow(minnow.trim)

table(minnow.trim$scientific_name.x)
#8 species; 446 images

write.csv(minnow.trim, "minnows.timmed.burress.csv")
