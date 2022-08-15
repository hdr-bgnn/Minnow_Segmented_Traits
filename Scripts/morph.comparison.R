# comparison of traits using morphology tt.align, morphology 0.1.1, and morphology 0.2.0
# Meghan Balk 
# balk@battelleecology.org

library(rjson)
library(tidyr)
library(dplyr)
library(stringr)
library(reshape2)

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile, unexpected.escape = "keep")
  df <- as.data.frame(input)
  df$scale <- as.numeric(df$scale) #for some reason there are "doubles"; making them all the same
  #will get warnings because NA are created since some df$scales are characters ("none")
  return(df)
}

#get list of file names
#path is in the OSC 
setwd("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows/Morphology_tt_align_test/Measure")
m.tt.align.files <- list.files(pattern = '*.json')

m.tt.align.df <- lapply(m.tt.align.files, json_df) %>%
  dplyr::bind_rows()

setwd("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows/Morphology_0_1_1/Measure")
m.0.1.1.files <- list.files(pattern = '*.json')

m.0.1.1.df <- lapply(m.0.1.1.files, json_df) %>% 
  dplyr::bind_rows()

setwd("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows/Morphology/Measure")
m.0.2.0.files <- list.files(pattern = '*.json')

m.0.2.0.df <- lapply(m.0.2.0.files, json_df) %>% 
  dplyr::bind_rows()

SL_bbox.diff <- m.0.2.0.df$SL_bbox - m.tt.align.df$SL_bbox
SL_lm.diff <- m.0.2.0.df$SL_lm - m.tt.align.df$SL_lm
HL_bbox.diff <- m.0.2.0.df$HL_bbox - m.tt.align.df$HL_bbox
HL_lm.diff <- m.0.2.0.df$HL_lm - m.tt.align.df$HL_lm
ED_bbox.diff <- m.0.2.0.df$ED_bbox - m.tt.align.df$ED_bbox
ED_lm.diff <- m.0.2.0.df$ED_lm - m.tt.align.df$ED_lm
pOD_bbox.diff <- m.0.2.0.df$pOD_bbox - m.tt.align.df$pOD_bbox
pOD_lm.diff <- m.0.2.0.df$pOD_lm - m.tt.align.df$pOD_lm
HH_lm.diff <- m.0.2.0.df$HH_lm - m.tt.align.df$HH_lm
FA_lm.diff <- m.0.2.0.df$FA_lm - m.tt.align.df$FA_lm
FA_pca.diff <- m.0.2.0.df$FA_pca - m.tt.align.df$FA_pca
FA_pca_meta.diff <- m.0.2.0.df$FA_pca_meta - m.tt.align.df$FA_pca_meta

