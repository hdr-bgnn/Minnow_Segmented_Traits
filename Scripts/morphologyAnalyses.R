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
library(ggpubr)

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

write.csv(measure.df.scale, "measure.df.errors.removed.csv", row.names = FALSE)

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

#convert scale
meta.measure.df.scale$SL_bbox.conv <- round(((meta.measure.df.scale$SL_bbox/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$SL_lm.conv <- round(((meta.measure.df.scale$SL_lm/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$HL_bbox.conv <- round(((meta.measure.df.scale$HL_bbox/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$HL_lm.conv <- round(((meta.measure.df.scale$HL_lm/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$pOD_bbox.conv <- round(((meta.measure.df.scale$pOD_bbox/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$pOD_lm.conv <- round(((meta.measure.df.scale$pOD_lm/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$ED_bbox.conv <- round(((meta.measure.df.scale$ED_bbox/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$ED_lm.conv <- round(((meta.measure.df.scale$ED_lm/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$HH_lm.conv <- round(((meta.measure.df.scale$HH_lm/meta.measure.df.scale$scale)*10), digits = 2)
meta.measure.df.scale$EA_m.conv <- round(((meta.measure.df.scale$EA_m/(meta.measure.df.scale$scale^2))*10), digits = 2)
meta.measure.df.scale$HA_m.conv <- round(((meta.measure.df.scale$HA_m/(meta.measure.df.scale$scale^2))*10), digits = 2)
meta.measure.df.scale$unit.conv <- "mm"
  
write.csv(meta.measure.df.scale, "meta.merged.measure.burress.errors.removed.rescaled.csv", 
          row.names = FALSE)

#add burress
#load Burress to compare
b.df <- read.csv("Previous Fish Measurements - Burress et al. 2016.csv", header = TRUE)

names(b.df)[2:10] <- paste0("b.",names(b.df)[2:10])

b.meta.measure.df.scale <- merge(b.df, meta.measure.df.scale,
                                 by.x = "Species",
                                 by.y = "scientific_name",
                                 all.x = FALSE, all.y = TRUE)

##get sp averages and se for fish measurements
measure_stats = b.meta.measure.df.scale %>%
  dplyr::group_by(Species) %>%
  dplyr::summarise(sample.size = n(),
                   crit.t = abs(qt(p = 0.025, df = (sample.size - 1))),
                   
                   b.N = b.N[1],
                   b.SL = b.SL[1],
                   b.HL = b.HL[1],
                   b.SnL = b.SnL[1],
                   b.ED = b.ED[1],
                   b.HH = b.HD[1],
                   
                   min.SL_bbox = min(SL_bbox.conv, na.rm = TRUE),
                   max.SL_bbox  = max(SL_bbox.conv, na.rm = TRUE),
                   avg.SL_bbox = mean(SL_bbox.conv, na.rm = TRUE),
                   sd.SL_bbox = sd(SL_bbox.conv, na.rm = TRUE),
                   se.err.SL_bbox = sd.SL_bbox/sqrt(sample.size),
                   abs.se.diff.SL_bbox = abs((b.SL - avg.SL_bbox)/se.err.SL_bbox), #absolute masss.diff.se observed t; number in t-units (counts of standard errors from each mean)
                   SL_bbox.3se = abs.se.diff.SL_bbox > 3, #outside.3.sigma; if true then greater than 3 std errors outside
                   SL_bbox.sig = (abs.se.diff.SL_bbox-crit.t) > 0, #sig = true means sig diff
                   SL_bbox.pvalue.crit.t = 1-pt(abs.se.diff.SL_bbox, df = (sample.size-1)), #p.value.fromt.crit.t; if p=0.05 then most of it is outside
                   SL_bbox.pvalue = t.test(SL_bbox, mu = b.SL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   SL_bbox.per.diff = abs(((avg.SL_bbox - b.SL)/avg.SL_bbox)*100),
                   SL_bbox.pvalue.corr = p.adjust(SL_bbox.pvalue, method = "BH"),
                   SL_bbox.t.value.corr = p.adjust(SL_bbox.pvalue.crit.t, method = "BH"),
                   SL_bbox.pvalue.sig.corr = SL_bbox.pvalue.corr <= 0.05, #TRUE means sig diff
                   SL_bbox.t.value.sig.corr = SL_bbox.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.SL_lm = min(SL_lm.conv, na.rm = TRUE),
                   max.SL_lm  = max(SL_lm.conv, na.rm = TRUE),
                   avg.SL_lm = mean(SL_lm.conv, na.rm = TRUE),
                   sd.SL_lm = sd(SL_lm.conv, na.rm = TRUE),
                   se.err.SL_lm = sd.SL_lm/sqrt(sample.size),
                   abs.se.diff.SL_lm = abs((b.SL - avg.SL_lm)/se.err.SL_lm),
                   SL_lm.3se = abs.se.diff.SL_lm > 3,
                   SL_lm.sig = (abs.se.diff.SL_lm-crit.t) > 0,
                   SL_lm.pvalue.crit.t = 1-pt(abs.se.diff.SL_lm, df = (sample.size-1)),
                   SL_lm.pvalue = t.test(SL_lm, mu = b.SL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   SL_lm.per.diff = abs(((avg.SL_lm - b.SL)/avg.SL_lm)*100),
                   SL_lm.pvalue.corr = p.adjust(SL_lm.pvalue, method = "BH"),
                   SL_lm.t.value.corr = p.adjust(SL_lm.pvalue.crit.t, method = "BH"),
                   SL_lm.pvalue.sig.corr = SL_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   SL_lm.t.value.sig.corr = SL_lm.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.HL_bbox = min(HL_bbox.conv, na.rm = TRUE),
                   max.HL_bbox  = max(HL_bbox.conv, na.rm = TRUE),
                   avg.HL_bbox = mean(HL_bbox.conv, na.rm = TRUE),
                   sd.HL_bbox = sd(HL_bbox.conv, na.rm = TRUE),
                   se.err.HL_bbox = sd.HL_bbox/sqrt(sample.size),
                   abs.se.diff.HL_bbox = abs((b.HL - avg.HL_bbox)/se.err.HL_bbox),
                   HL_bbox.3se = abs.se.diff.HL_bbox > 3,
                   HL_bbox.sig = abs.se.diff.HL_bbox-crit.t > 0,
                   HL_bbox.pvalue.crit.t = 1-pt(abs.se.diff.HL_bbox, df = (sample.size-1)),
                   HL_bbox.pvalue = t.test(HL_bbox, mu = b.HL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   HL_bbox.per.diff = abs(((avg.HL_bbox - b.HL)/avg.HL_bbox)*100),
                   HL_bbox.pvalue.corr = p.adjust(HL_bbox.pvalue, method = "BH"),
                   HL_bbox.t.value.corr = p.adjust(HL_bbox.pvalue.crit.t, method = "BH"),
                   HL_bbox.pvalue.sig.corr = HL_bbox.pvalue.corr <= 0.05, #TRUE means sig diff
                   HL_bbox.t.value.sig.corr = HL_bbox.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.HL_lm = min(HL_lm.conv, na.rm = TRUE),
                   max.HL_lm  = max(HL_lm.conv, na.rm = TRUE),
                   avg.HL_lm = mean(HL_lm.conv, na.rm = TRUE),
                   sd.HL_lm = sd(HL_lm.conv, na.rm = TRUE),
                   se.err.HL_lm = sd.HL_lm/sqrt(sample.size),
                   abs.se.diff.HL_lm = abs((b.HL - avg.HL_lm)/se.err.HL_lm),
                   HL_lm.3se = abs.se.diff.HL_lm > 3,
                   HL_lm.sig = abs.se.diff.HL_lm-crit.t > 0,
                   HL_lm.pvalue.crit.t = 1-pt(abs.se.diff.HL_lm, df = (sample.size-1)),
                   HL_lm.pvalue = t.test(HL_lm, mu = b.HL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   HL_lm.per.diff = abs(((avg.HL_lm - b.HL)/avg.HL_lm)*100),
                   HL_lm.pvalue.corr = p.adjust(HL_lm.pvalue, method = "BH"),
                   HL_lm.t.value.corr = p.adjust(HL_lm.pvalue.crit.t, method = "BH"),
                   HL_lm.pvalue.sig.corr = HL_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   HL_lm.t.value.sig.corr = HL_lm.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.pOD_bbox = min(pOD_bbox.conv, na.rm = TRUE),
                   max.pOD_bbox  = max(pOD_bbox.conv, na.rm = TRUE),
                   avg.pOD_bbox = mean(pOD_bbox.conv, na.rm = TRUE),
                   sd.pOD_bbox = sd(pOD_bbox.conv, na.rm = TRUE),
                   se.err.pOD_bbox = sd.pOD_bbox/sqrt(sample.size),
                   abs.se.diff.pOD_bbox = abs((b.SnL - avg.pOD_bbox)/se.err.pOD_bbox),
                   pOD_bbox.3se = abs.se.diff.pOD_bbox > 3,
                   pOD_bbox.sig = abs.se.diff.pOD_bbox-crit.t > 0,
                   pOD_bbox.pvalue.crit.t = 1-pt(abs.se.diff.pOD_bbox, df = (sample.size-1)),
                   pOD_bbox.pvalue = t.test(pOD_bbox, mu = b.SnL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   pOD_bbox.per.diff = abs(((avg.pOD_bbox - b.SnL)/avg.pOD_bbox)*100),
                   pOD_bbox.pvalue.corr = p.adjust(pOD_bbox.pvalue, method = "BH"),
                   pOD_bbox.t.value.corr = p.adjust(pOD_bbox.pvalue.crit.t, method = "BH"),
                   pOD_bbox.pvalue.sig.corr = pOD_bbox.pvalue.corr <= 0.05, #TRUE means sig diff
                   pOD_bbox.t.value.sig.corr = pOD_bbox.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.pOD_lm = min(pOD_lm.conv, na.rm = TRUE),
                   max.pOD_lm  = max(pOD_lm.conv, na.rm = TRUE),
                   avg.pOD_lm = mean(pOD_lm.conv, na.rm = TRUE),
                   sd.pOD_lm = sd(pOD_lm.conv, na.rm = TRUE),
                   se.err.pOD_lm = sd.pOD_lm/sqrt(sample.size),
                   abs.se.diff.pOD_lm = abs((b.SnL - avg.pOD_lm)/se.err.pOD_lm),
                   pOD_lm.3se = abs.se.diff.pOD_lm > 3,
                   pOD_lm.sig = abs.se.diff.pOD_lm-crit.t > 0,
                   pOD_lm.pvalue.crit.t = 1-pt(abs.se.diff.pOD_lm, df = (sample.size-1)),
                   pOD_lm.pvalue = t.test(pOD_lm, mu = b.SnL, conf.level = 0.95, alternative = "two.sided")$p.value,
                   pOD_lm.per.diff = abs(((avg.pOD_lm - b.SnL)/avg.pOD_lm)*100),
                   pOD_lm.pvalue.corr = p.adjust(pOD_lm.pvalue, method = "BH"),
                   pOD_lm.t.value.corr = p.adjust(pOD_lm.pvalue.crit.t, method = "BH"),
                   pOD_lm.pvalue.sig.corr = pOD_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   pOD_lm.t.value.sig.corr = pOD_lm.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.ED_bbox = min(ED_bbox.conv, na.rm = TRUE),
                   max.ED_bbox  = max(ED_bbox.conv, na.rm = TRUE),
                   avg.ED_bbox = mean(ED_bbox.conv, na.rm = TRUE),
                   sd.ED_bbox = sd(ED_bbox.conv, na.rm = TRUE),
                   se.err.ED_bbox = sd.ED_bbox/sqrt(sample.size),
                   abs.se.diff.ED_bbox = abs((b.ED - avg.ED_bbox)/se.err.ED_bbox),
                   ED_bbox.3se = abs.se.diff.ED_bbox > 3,
                   ED_bbox.sig = abs.se.diff.ED_bbox-crit.t > 0,
                   ED_bbox.pvalue.crit.t = 1-pt(abs.se.diff.ED_bbox, df = (sample.size-1)),
                   ED_bbox.pvalue = t.test(ED_bbox, mu = b.ED, conf.level = 0.95, alternative = "two.sided")$p.value,
                   ED_bbox.per.diff = abs(((avg.ED_bbox - b.ED)/avg.ED_bbox)*100),
                   ED_bbox.pvalue.corr = p.adjust(ED_bbox.pvalue, method = "BH"),
                   ED_bbox.t.value.corr = p.adjust(ED_bbox.pvalue.crit.t, method = "BH"),
                   ED_bbox.pvalue.sig.corr = ED_bbox.pvalue.corr <= 0.05, #TRUE means sig diff
                   ED_bbox.t.value.sig.corr = ED_bbox.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.ED_lm = min(ED_lm.conv, na.rm = TRUE),
                   max.ED_lm  = max(ED_lm.conv, na.rm = TRUE),
                   avg.ED_lm = mean(ED_lm.conv, na.rm = TRUE),
                   sd.ED_lm = sd(ED_lm.conv, na.rm = TRUE),
                   se.err.ED_lm = sd.ED_lm /sqrt(sample.size),
                   abs.se.diff.ED_lm = abs((b.ED - avg.ED_lm)/se.err.ED_lm),
                   ED_lm.3se = abs.se.diff.ED_lm > 3,
                   ED_lm.sig = abs.se.diff.ED_lm-crit.t > 0,
                   ED_lm.pvalue.crit.t = 1-pt(abs.se.diff.ED_lm, df = (sample.size-1)),
                   ED_lm.pvalue = t.test(ED_lm, mu = b.ED, conf.level = 0.95, alternative = "two.sided")$p.value,
                   ED_lm.per.diff = abs(((avg.ED_lm - b.ED)/avg.ED_lm)*100),
                   ED_lm.pvalue.corr = p.adjust(ED_lm.pvalue, method = "BH"),
                   ED_lm.t.value.corr = p.adjust(ED_lm.pvalue.crit.t, method = "BH"),
                   ED_lm.pvalue.sig.corr = ED_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   ED_lm.t.value.sig.corr = ED_lm.t.value.corr <= 0.05, #TRUE means sig diff
                   
                   min.HH_lm = min(HH_lm.conv, na.rm = TRUE),
                   max.HH_lm  = max(HH_lm.conv, na.rm = TRUE),
                   avg.HH_lm = mean(HH_lm.conv, na.rm = TRUE),
                   sd.HH_lm = sd(HH_lm.conv, na.rm = TRUE),
                   se.err.HH_lm = sd.HH_lm/sqrt(sample.size),
                   abs.se.diff.HH_lm = abs((b.HH - avg.HH_lm)/se.err.HH_lm),
                   HH_lm.3se = abs.se.diff.HH_lm > 3,
                   HH_lm.sig = abs.se.diff.HH_lm-crit.t > 0,
                   HH_lm.pvalue.crit.t = 1-pt(abs.se.diff.HH_lm, df = (sample.size-1)),
                   HH_lm.pvalue = t.test(HH_lm, mu = b.HH, conf.level = 0.95, alternative = "two.sided")$p.value,                   
                   HH_lm.per.diff = abs(((avg.HH_lm - b.HH)/avg.HH_lm)*100),
                   HH_lm.pvalue.corr = p.adjust(HH_lm.pvalue, method = "BH"),
                   HH_lm.t.value.corr = p.adjust(HH_lm.pvalue.crit.t, method = "BH"),
                   HH_lm.pvalue.sig.corr = HH_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   HH_lm.t.value.sig.corr = HH_lm.t.value.corr <= 0.05) %>% #TRUE means sig diff
  as.data.frame()

write.csv(measure_stats, "measurement.stats.burress.csv", row.names = FALSE)
  
##series of density plots with the distrbution of measurements and the avg from Burress
# one per species

#create datasets by species
df.trim <- meta.measure.df.scale[, -c(2:5, 11:26, 28:32)]
df.melt <- melt(df.trim, id.vars = c(1:7, 19))
df.melt$variable <- as.factor(df.melt$variable)
sp <- unique(df.melt$scientific_name)
vs <- unique(df.melt$variable)

for(i in 1:length(sp)){
sl.p <- ggplot(data = df.melt[df.melt$variable == vs[1:2] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = value, fill = variable), alpha = 0.25) +
# ggtitle("Notropis volucellus: comparison of measurements using bbox and lm compared to Burress et al. 2017") + 
  scale_x_continuous(name = 'Standard length (mm)') + 
  scale_y_continuous(name = 'Density') + 
  scale_fill_discrete(labels = c('SL, bbox', 'SL, lm')) +
  geom_vline(xintercept = b.df$b.SL[b.df$Species == sp[1]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

hl.p <- ggplot(data = df.melt[df.melt$variable == vs[3:4] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = value, fill = variable), alpha = 0.25) +
# ggtitle("Notropis volucellus: comparison of measurements using bbox and lm compared to Burress et al. 2017") + 
  scale_x_continuous(name = 'Head length (mm)') + 
  scale_y_continuous(name = 'Density') + 
  scale_fill_discrete(labels = c('HL, bbox', 'HL, lm')) +
  geom_vline(xintercept = b.df$b.HL[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

pod.p <- ggplot(data = df.melt[df.melt$variable == vs[5:6] &
                               df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = value, fill = variable), alpha = 0.25) +
# ggtitle("Notropis volucellus: comparison of measurements using bbox and lm compared to Burress et al. 2017") + 
  scale_x_continuous(name = 'Preorbital length (mm)') + 
  scale_y_continuous(name = 'Density') + 
  scale_fill_discrete(labels = c('pOD, bbox', 'pOD, lm')) +
  geom_vline(xintercept = b.df$b.SnL[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ed.p <- ggplot(data = df.melt[df.melt$variable == vs[7:8] &
                                   df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = value, fill = variable), alpha = 0.25) +
# ggtitle("Notropis volucellus: comparison of measurements using bbox and lm compared to Burress et al. 2017") + 
  scale_x_continuous(name = 'Eye diameter (mm)') + 
  scale_y_continuous(name = 'Density') + 
  scale_fill_discrete(labels = c('ED, bbox', 'ED, lm')) +
  geom_vline(xintercept = b.df$b.ED[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

hh.p <- ggplot(data = df.melt[df.melt$variable == vs[9] &
                                   df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = value, fill = variable), alpha = 0.25) +
# ggtitle("Notropis volucellus: comparison of measurements using bbox and lm compared to Burress et al. 2017") + 
  scale_x_continuous(name = 'Head height (mm)') + 
  scale_y_continuous(name = 'Density') + 
  scale_fill_discrete(labels = c('HH, lm')) +
  geom_vline(xintercept = b.df$b.HD[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

fig <- ggarrange(sl.p, hl.p, pod.p, ed.p, hh.p,
                   labels = c("SL", "HL", "pOD", "ED", "HH"),
                   ncol = 3, nrow = 2)

ggsave(fig, file=paste0(sp[i],": comparison of measurements (Burress et al. 2017 dashed line)", ".png"), 
       width =100, height = 50, units = "cm")
}


