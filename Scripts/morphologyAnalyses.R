# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)
library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr)
library(RColorBrewer)
library(reshape2)

#get list of file names
#path is in the OSC 
setwd("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows/Morphology/Measure")
m.files <- list.files(pattern = '*.json')

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile, unexpected.escape = "keep")
  #some json files have null for scale (index 15 & 16)
  if(isTRUE(is.null(input[15][[1]][[1]]))){
    input[15][[1]][[1]] <- "none"
  }
  if(isTRUE(is.null(input[16][[1]][[1]]))){
    input[16][[1]][[1]] <- "none"
  }
  df <- as.data.frame(input)
  df$file.name <- gsub(jfile,
                       pattern = "_measure.json", #can change this depending on the file name
                       replacement = "")
  return(df)
}

measure.df <- lapply(m.files, json_df) %>% 
  dplyr::bind_rows()

#check have all the files
nrow(measure.df) #446
length(m.files) #446

str(measure.df)
View(measure.df)

#in files dir
write.csv(measure.df, "measure.df.burress.csv", row.names = FALSE)

#remove those that don't have a scale
errors <- measure.df[measure.df$X.none. == "none",] %>% drop_na(X.none.)
nrow(errors) #18 images

write.csv(errors, "measure.df.missing.scale.csv", row.names = FALSE)

measure.df.scale <- measure.df[!(measure.df$base_name %in% errors$base_name),]

#need to combine metatdata about fish
setwd("/users/PAS2136/balkm/minnowTraits/Files/")
meta <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE)

#remove file extension
meta$original_file_name <- gsub(meta$original_file_name,
                                pattern = ".jpg",
                                replacement = "")

#merge
meta.measure.df.scale <- merge(meta, measure.df.scale, 
                               by.x = "original_file_name",
                               by.y = "base_name",
                               all.x = FALSE, all.y = TRUE)

write.csv(meta.measure.df.scale, "meta.merged.measure.burress.errors.removed.csv", 
          row.names = FALSE)

#load Burress to compare
b.df <- read.csv("Previous Fish Measurements - Burress et al. 2016.csv", header = TRUE)

#convert scale
meta.measure.df.scale$SL_bbox_conv <- meta.measure.df.scale$SL_bbox/meta.measure.df.scale$scale
meta.measure.df.scale$SL_lm_conv <- meta.measure.df.scale$SL_lm/meta.measure.df.scale$scale
meta.measure.df.scale$HL_bbox_conv <- meta.measure.df.scale$HL_bbox/meta.measure.df.scale$scale
meta.measure.df.scale$HL_lm_conv <- meta.measure.df.scale$HL_lm/meta.measure.df.scale$scale
meta.measure.df.scale$pOD_bbox_conv <- meta.measure.df.scale$pOD_bbox/meta.measure.df.scale$scale
meta.measure.df.scale$pOD_lm_conv <- meta.measure.df.scale$pOD_lm/meta.measure.df.scale$scale
meta.measure.df.scale$ED_bbox_conv <- meta.measure.df.scale$ED_bbox/meta.measure.df.scale$scale
meta.measure.df.scale$ED_lm_conv <- meta.measure.df.scale$ED_lm/meta.measure.df.scale$scale
meta.measure.df.scale$HH_lm_conv <- meta.measure.df.scale$HH_lm/meta.measure.df.scale$scale
meta.measure.df.scale$EA_m_conv <- meta.measure.df.scale$EA_m/meta.measure.df.scale$scale
meta.measure.df.scale$HA_m_conv <- meta.measure.df.scale$HA_m/meta.measure.df.scale$scale

##get sp averages and se for fish measurements
measure_stats <- meta.measure.df.scale %>%
  dplyr::group_by(scientific_name) %>%
  dplyr::summarise(sample.size = n(), 
                   
                   min.HL_bbox = min(HL_bbox_conv, na.rm = TRUE),
                   max.HL_bbox  = max(HL_bbox_conv, na.rm = TRUE),
                   avg.HL_bbox = mean(HL_bbox_conv, na.rm = TRUE),
                   sd.err.HL_bbox = sd(HL_bbox_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.SL_lm = min(SL_lm_conv, na.rm = TRUE),
                   max.SL_lm  = max(SL_lm_conv, na.rm = TRUE),
                   avg.SL_lm = mean(SL_lm_conv, na.rm = TRUE),
                   sd.err.SL_lm = sd(SL_lm_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.HL_bbox = min(HL_bbox_conv, na.rm = TRUE),
                   max.HL_bbox  = max(HL_bbox_conv, na.rm = TRUE),
                   avg.HL_bbox = mean(HL_bbox_conv, na.rm = TRUE),
                   sd.err.HL_bbox = sd(HL_bbox_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.HL_lm = min(HL_lm_conv, na.rm = TRUE),
                   max.HL_lm  = max(HL_lm_conv, na.rm = TRUE),
                   avg.HL_lm = mean(HL_lm_conv, na.rm = TRUE),
                   sd.err.HL_lm = sd(HL_lm_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.pOD_bbox = min(pOD_bbox_conv, na.rm = TRUE),
                   max.pOD_bbox  = max(pOD_bbox_conv, na.rm = TRUE),
                   avg.pOD_bbox = mean(pOD_bbox_conv, na.rm = TRUE),
                   sd.err.pOD_bbox = sd(pOD_bbox_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.pOD_lm = min(pOD_lm_conv, na.rm = TRUE),
                   max.pOD_lm  = max(pOD_lm_conv, na.rm = TRUE),
                   avg.pOD_lm = mean(pOD_lm_conv, na.rm = TRUE),
                   sd.err.pOD_lm = sd(pOD_lm_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.ED_bbox = min(ED_bbox_conv, na.rm = TRUE),
                   max.ED_bbox  = max(ED_bbox_conv, na.rm = TRUE),
                   avg.ED_bbox = mean(ED_bbox_conv, na.rm = TRUE),
                   sd.err.ED_bbox = sd(ED_bbox_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.ED_lm = min(ED_lm_conv, na.rm = TRUE),
                   max.ED_lm  = max(ED_lm_conv, na.rm = TRUE),
                   avg.ED_lm = mean(ED_lm_conv, na.rm = TRUE),
                   sd.err.ED_lm = sd(ED_lm_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.HH_lm = min(HH_lm_conv, na.rm = TRUE),
                   max.HH_lm  = max(HH_lm_conv, na.rm = TRUE),
                   avg.HH_lm = mean(HH_lm_conv, na.rm = TRUE),
                   sd.err.HH_lm = sd(HH_lm_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.EA_m = min(EA_m_conv, na.rm = TRUE),
                   max.EA_m  = max(EA_m_conv, na.rm = TRUE),
                   avg.EA_m = mean(EA_m_conv, na.rm = TRUE),
                   sd.err.EA_m = sd(EA_m_conv, na.rm = TRUE)/sqrt(sample.size),
                   
                   min.HA_m = min(HA_m_conv, na.rm = TRUE),
                   max.HA_m  = max(HA_m_conv, na.rm = TRUE),
                   avg.HA_m = mean(HA_m_conv, na.rm = TRUE),
                   sd.err.HA_m = sd(HA_m_conv, na.rm = TRUE)/sqrt(sample.size)) %>%
  as.data.frame()
                   
#add burress to stats

names.change <- grep("^[A-Z]+$", names(b.df))
names(b.df)[names.change] <- paste0("b.",names(b.df)[names.change])

b.measure.stats <- merge(b.df, measure_stats, 
                         by.x = "Species", 
                         by.y = "scientific_name",
                         all.x = FALSE, all.y = TRUE)
            

  
                   pan.mass = X5.1_AdultBodyMass_g[1],
                   mass.diff = (pan.mass - avg.mass),
                   mass.diff.se = mass.diff / sd.err.mass,
                   abs.mass.diff.se = abs(mass.diff.se), #observed t; number in t-units (counts of standard errors from each mean)
                   outside.3.sigma = abs.mass.diff.se > 3, #if true then greater than 3 std errors outside
                   critical.t = abs(qt(p = 0.025, df = (sample.size-1))),
                   diff.amt = abs.mass.diff.se-critical.t,
                   sig = diff.amt > 0, # true means sig diff
                   p.value.fromt.crit.t = 1-pt(abs.mass.diff.se, df = (sample.size-1)), #if p=0.05 then most of it is outside
                   p.value = t.test(measurementValue, mu = pan.mass, conf.level = 0.95, alternative = "two.sided")$p.value,
                   per.diff = abs(((avg.mass - pan.mass)/avg.mass)*100)) %>%
  as.data.frame()