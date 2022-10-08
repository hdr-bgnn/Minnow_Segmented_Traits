# comparison of measurements to previous measurement
# Meghan Balk 
# balk@battelleecology.org

## MAKE SURE WD IS IN REPO
#setwd("minnowTraits")

#### add to sampling.df ----
sampling.df <- read.csv(file = file.path(results, "sampling.df.seg.csv"),
                        header = TRUE)

# Files created by this script:
# 1. table of sampling as selection criteria applied
# 2. new data set of all the measure .json files
# 3. new data set that only keeps with a scale and pixels converted to mm
# 4. list of images without a scale
# 5. data frame of statistics
# 6. 8 plots: comparison of measurements to Burress et al. 2017 for each 
#    measurement type in a single panel


#### json to df ----
# files are the in the Presences folder
# get list of file names
m.files <- list.files(path = file.path("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows", measure), pattern = '*.json')

# turn into csv
# need to be in directory to grab the files 
setwd(file.path("/fs/ess/PAS2136/BGNN/Burress_et_al_2017_minnows", measure))
measure.df <- lapply(m.files, json_df, type = "_measure") %>% #list of dataframes
  dplyr::bind_rows() #rbind to turn into single dataframes

#check have all the files
nrow(measure.df) #446
length(m.files) #446

str(measure.df)
View(measure.df)

# write data frame to Results directory
## RESET DIRECTORY
setwd("/users/PAS2136/balkm/minnowTraits")
write.csv(measure.df, 
          file = file.path(results, "morphology.df.csv"),
          row.names = FALSE)

## 10. remove those that don't have a scale ----

sampling.df$Selection_Criteria[10] <- "Has ruler scale"

unique(measure.df$unit) #None means no scale was detected or extracted
errors <- measure.df[measure.df$unit == "None",] %>% drop_na(unit)
nrow(errors) #18 images

write.csv(errors, 
          file = file.path(results, "measure.df.missing.scale.csv"),
          row.names = FALSE)

measure.df.scale <- measure.df[!(measure.df$base_name %in% errors$base_name),]

write.csv(measure.df.scale, 
          file = file.path(results, "measure.df.errors.removed.csv"), 
          row.names = FALSE)

##need to combine metatdata about fish
#merge
meta.measure.df.scale <- merge(meta.df, measure.df.scale, 
                               by.x = "original_file_name",
                               by.y = "base_name",
                               all.x = FALSE, all.y = TRUE)

sampling.df$All_Minnows_Images_sp[10] <- paste0(nrow(meta.measure.df.scale),
                                                " (",
                                                length(unique(meta.measure.df.scale$scientific_name)),
                                                ")")

sampling.df$Burress_et_al._2017_Overlap_Images_sp[10] <- paste0(nrow(meta.measure.df.scale[meta.measure.df.scale$scientific_name %in% b.sp,]),
                                                                " (",
                                                                length(unique(meta.measure.df.scale$scientific_name[meta.measure.df.scale$scientific_name %in% b.sp])),
                                                                ")")

write.csv(sampling.df,
          file = file.path(figures, "sampling.table.csv"),
          row.names = FALSE)

#### convert scale ----
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

write.csv(meta.measure.df.scale, 
          file = file.path(results, "meta.merged.measure.burress.errors.removed.rescaled.csv"), 
          row.names = FALSE)

## combine with Burress et al. 2017
b.meta.measure.df.scale <- merge(b.df, meta.measure.df.scale,
                                 by.x = "Species",
                                 by.y = "scientific_name",
                                 all.x = FALSE, all.y = TRUE)

#### calculate statistics and moments ----

measure_stats = b.meta.measure.df.scale %>%
  dplyr::group_by(Species) %>%
  dplyr::summarise(sample.size = n(),
                   crit.t = abs(qt(p = 0.025, df = (sample.size - 1))),
                   
                   b.N = b.N[1],
                   b.SL = b.SL[1],
                   b.HL = b.HL[1],
                   b.SnL = b.SnL[1],
                   b.ED = b.ED[1],
                   b.HD = b.HD[1],
                   
                   min.SL_bbox = min(SL_bbox.conv, na.rm = TRUE),
                   max.SL_bbox  = max(SL_bbox.conv, na.rm = TRUE),
                   avg.SL_bbox = mean(SL_bbox.conv, na.rm = TRUE),
                   med.SL_bbox = median(SL_bbox.conv, na.rm = TRUE),
                   kurt.SL_bbox = round(kurtosis(SL_bbox.conv), digits = 2),
                   sd.SL_bbox = sd(SL_bbox.conv, na.rm = TRUE),
                   se.err.SL_bbox = sd.SL_bbox/sqrt(sample.size),
                   se.diff.SL_bbox = (b.SL - avg.SL_bbox)/se.err.SL_bbox, #absolute masss.diff.se observed t; number in t-units (counts of standard errors from each mean)
                   abs.se.diff.SL_bbox = abs(se.diff.SL_bbox), #absolute masss.diff.se observed t; number in t-units (counts of standard errors from each mean)
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
                   med.SL_lm = median(SL_lm.conv, na.rm = TRUE),
                   kurt.SL_lm = round(kurtosis(SL_lm.conv), digits = 2),
                   sd.SL_lm = sd(SL_lm.conv, na.rm = TRUE),
                   se.err.SL_lm = sd.SL_lm/sqrt(sample.size),
                   se.diff.SL_lm = (b.SL - avg.SL_lm)/se.err.SL_lm,
                   abs.se.diff.SL_lm = abs(se.diff.SL_lm),
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
                   med.HL_bbox = median(HL_bbox.conv, na.rm = TRUE),
                   kurt.HL_bbox = round(kurtosis(HL_bbox.conv), digits = 2),
                   sd.HL_bbox = sd(HL_bbox.conv, na.rm = TRUE),
                   se.err.HL_bbox = sd.HL_bbox/sqrt(sample.size),
                   se.diff.HL_bbox = (b.HL - avg.HL_bbox)/se.err.HL_bbox,
                   abs.se.diff.HL_bbox = abs(se.diff.HL_bbox),
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
                   med.HL_lm = median(HL_lm.conv, na.rm = TRUE),
                   kurt.HL_lm = round(kurtosis(HL_lm.conv), digits = 2),
                   sd.HL_lm = sd(HL_lm.conv, na.rm = TRUE),
                   se.err.HL_lm = sd.HL_lm/sqrt(sample.size),
                   se.diff.HL_lm = (b.HL - avg.HL_lm)/se.err.HL_lm,
                   abs.se.diff.HL_lm = abs(se.diff.HL_lm),
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
                   med.pOD_bbox = median(pOD_bbox.conv, na.rm = TRUE),
                   kurt.pOD_bbox = round(kurtosis(pOD_bbox.conv), digits = 2),
                   sd.pOD_bbox = sd(pOD_bbox.conv, na.rm = TRUE),
                   se.err.pOD_bbox = sd.pOD_bbox/sqrt(sample.size),
                   se.diff.pOD_bbox = (b.SnL - avg.pOD_bbox)/se.err.pOD_bbox,
                   abs.se.diff.pOD_bbox = abs(se.diff.pOD_bbox),
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
                   med.pOD_lm = median(pOD_lm.conv, na.rm = TRUE),
                   kurt.pOD_lm = round(kurtosis(pOD_lm.conv), digits = 2),
                   sd.pOD_lm = sd(pOD_lm.conv, na.rm = TRUE),
                   se.err.pOD_lm = sd.pOD_lm/sqrt(sample.size),
                   se.diff.pOD_lm = (b.SnL - avg.pOD_lm)/se.err.pOD_lm,
                   abs.se.diff.pOD_lm = abs(se.diff.pOD_lm),
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
                   med.ED_bbox = median(ED_bbox.conv, na.rm = TRUE),
                   kurt.ED_bbox = round(kurtosis(ED_bbox.conv), digits = 2),
                   sd.ED_bbox = sd(ED_bbox.conv, na.rm = TRUE),
                   se.err.ED_bbox = sd.ED_bbox/sqrt(sample.size),
                   se.diff.ED_bbox = (b.ED - avg.ED_bbox)/se.err.ED_bbox,
                   abs.se.diff.ED_bbox = abs(se.diff.ED_bbox),
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
                   med.ED_lm = median(ED_lm.conv, na.rm = TRUE),
                   kurt.ED_lm = round(kurtosis(ED_lm.conv), digits = 2),
                   sd.ED_lm = sd(ED_lm.conv, na.rm = TRUE),
                   se.err.ED_lm = sd.ED_lm /sqrt(sample.size),
                   se.diff.ED_lm = (b.ED - avg.ED_lm)/se.err.ED_lm,
                   abs.se.diff.ED_lm = abs(se.diff.ED_lm),
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
                   med.HH_lm = median(HH_lm.conv, na.rm = TRUE),
                   kurt.HH_lm = round(kurtosis(HH_lm.conv), digits = 2),
                   sd.HH_lm = sd(HH_lm.conv, na.rm = TRUE),
                   se.err.HH_lm = sd.HH_lm/sqrt(sample.size),
                   se.diff.HH_lm = (b.HD - avg.HH_lm)/se.err.HH_lm,
                   abs.se.diff.HH_lm = abs(se.diff.HH_lm),
                   HH_lm.3se = abs.se.diff.HH_lm > 3,
                   HH_lm.sig = abs.se.diff.HH_lm-crit.t > 0,
                   HH_lm.pvalue.crit.t = 1-pt(abs.se.diff.HH_lm, df = (sample.size-1)),
                   HH_lm.pvalue = t.test(HH_lm, mu = b.HD, conf.level = 0.95, alternative = "two.sided")$p.value,                   
                   HH_lm.per.diff = abs(((avg.HH_lm - b.HD)/avg.HH_lm)*100),
                   HH_lm.pvalue.corr = p.adjust(HH_lm.pvalue, method = "BH"),
                   HH_lm.t.value.corr = p.adjust(HH_lm.pvalue.crit.t, method = "BH"),
                   HH_lm.pvalue.sig.corr = HH_lm.pvalue.corr <= 0.05, #TRUE means sig diff
                   HH_lm.t.value.sig.corr = HH_lm.t.value.corr <= 0.05) %>% #TRUE means sig diff
  as.data.frame()

write.csv(measure_stats,
          file = file.path(results, "measurement.stats.burress.csv"),
          row.names = FALSE)

#### Figures: measurements per species per trait ----  
##series of density plots with the distribution of measurements and the avg from Burress
# one per species

#create datasets by species
columns.keep <- c("original_file_name", "dataset", "path",
                  "scientific_name", "genus", "family", "institution",
                  "SL_bbox.conv", "SL_lm.conv",
                  "HL_bbox.conv", "HL_lm.conv",
                  "ED_bbox.conv", "ED_lm.conv",
                  "pOD_bbox.conv", "pOD_lm.conv",
                  "HH_lm.conv",
                  "unit.conv")
df.trim <- meta.measure.df.scale[, names(meta.measure.df.scale) %in% columns.keep]
df.melt <- melt(df.trim, id.vars = c(1:7, 17),
                variable.name = "traits",
                value.name = "measurements")
df.melt$traits <- as.factor(df.melt$traits)
sp <- unique(df.melt$scientific_name)
traits <- unique(df.melt$traits) #order of variables

## colors
#bbox = tan4
#lm = darkgreen

for(i in 1:length(sp)){
sl.p <- ggplot(data = df.melt[df.melt$traits == traits[1:2] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = measurements, fill = traits), 
               alpha = 0.25) +
  geom_rug(data = df.melt[df.melt$traits == traits[1] & #lm and bbox basically overlap
                          df.melt$scientific_name == sp[i],],
           aes(x = measurements),
           sides = "b", col = "darkgrey", alpha = 0.25) +
  ggtitle(paste0(sp[i], ": comparison of Standard Length (Burress et al. 2017 dashed line)")) + 
  scale_x_continuous(name = 'Standard Length (mm)',
                     limits = c(0, 70)) + 
  scale_y_continuous(name = 'Density',
                     limits = c(0, 0.1)) + 
  scale_fill_manual(labels = c('SL, bbox', 'SL, lm'),
                    values = c("tan4", "darkgreen")) +
  geom_vline(xintercept = b.df$b.SL[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(sl.p, 
       file = file.path(figures, paste0(sp[i],": comparison of Standard Length (Burress et al. 2017 dashed line)", ".png")), 
       width =100, height = 50, units = "cm")

hl.p <- ggplot(data = df.melt[df.melt$traits == traits[3:4] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = measurements, fill = traits), alpha = 0.25) +
  geom_rug(data = df.melt[df.melt$traits == traits[3] & #lm and bbox basically overlap
                          df.melt$scientific_name == sp[i],],
           aes(x = measurements),
           sides = "b", col = "darkgrey", alpha = 0.25) +
  ggtitle(paste0(sp[i], ": comparison of Head Length (Burress et al. 2017 dashed line)")) + 
  scale_x_continuous(name = 'Head Length (mm)',
                     limits = c(0, 15)) + 
  scale_y_continuous(name = 'Density',
                     limits = c(0, 0.5)) + 
  scale_fill_manual(labels = c('HL, bbox', 'HL, lm'),
                    values = c("tan4", "darkgreen")) +
  geom_vline(xintercept = b.df$b.HL[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hl.p, 
       file = file.path(figures, paste0(sp[i],": comparison of Head Length (Burress et al. 2017 dashed line)", ".png")), 
       width =100, height = 50, units = "cm")

pod.p <- ggplot(data = df.melt[df.melt$traits == traits[5:6] &
                               df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = measurements, fill = traits), alpha = 0.25) +
  geom_rug(data = df.melt[df.melt$traits == traits[5] & #lm and bbox basically overlap
                          df.melt$scientific_name == sp[i],],
           aes(x = measurements),
           sides = "b", col = "darkgrey", alpha = 0.25) +
  ggtitle(paste0(sp[i], ": comparison of Preorbital Depth (Burress et al. 2017 dashed line)")) + 
  scale_x_continuous(name = 'Preorbital Depth (mm)',
                     limits = c(0, 5)) + 
  scale_y_continuous(name = 'Density',
                     limits = c(0, 1)) + 
  scale_fill_manual(labels = c('pOD, bbox', 'pOD, lm'),
                    values = c("tan4", "darkgreen")) +
  geom_vline(xintercept = b.df$b.SnL[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(pod.p, 
       file = file.path(figures, paste0(sp[i],": comparison of Preorbital Depth (Burress et al. 2017 dashed line)", ".png")), 
       width =100, height = 50, units = "cm")

ed.p <- ggplot(data = df.melt[df.melt$traits == traits[7:8] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = measurements, fill = traits), alpha = 0.25) +
  geom_rug(data = df.melt[df.melt$traits == traits[7] & #lm and bbox basically overlap
                            df.melt$scientific_name == sp[i],],
           aes(x = measurements),
           sides = "b", col = "darkgrey", alpha = 0.25) +
  ggtitle(paste0(sp[i], ": comparison of Eye Diameter (Burress et al. 2017 dashed line)")) + 
  scale_x_continuous(name = 'Eye Diameter (mm)',
                     limits = c(0, 5)) + 
  scale_y_continuous(name = 'Density',
                     limits = c(0, 1)) + 
  scale_fill_manual(labels = c('ED, bbox', 'ED, lm'),
                    values = c("tan4", "darkgreen")) +
  geom_vline(xintercept = b.df$b.ED[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(ed.p, 
       file = file.path(figures, paste0(sp[i],": comparison of Eye Diameter (Burress et al. 2017 dashed line)", ".png")), 
       width =100, height = 50, units = "cm")

hh.p <- ggplot(data = df.melt[df.melt$traits == traits[9] &
                              df.melt$scientific_name == sp[i],]) +
  geom_density(aes(x = measurements, fill = traits), alpha = 0.25) +
  geom_rug(data = df.melt[df.melt$traits == traits[9] & #lm and bbox basically overlap
                            df.melt$scientific_name == sp[i],],
           aes(x = measurements),
           sides = "b", col = "darkgrey", alpha = 0.25) +
  ggtitle(paste0(sp[i], ": comparison of Head Height (Burress et al. 2017 dashed line)")) + 
  scale_x_continuous(name = 'Head Height (mm)',
                     limits = c(0, 10)) + 
  scale_y_continuous(name = 'Density',
                     limits = c(0, .5)) + 
  scale_fill_manual(labels = c('HH, lm'),
                    values = "darkgreen") +
  geom_vline(xintercept = b.df$b.HD[b.df$Species == sp[i]], linetype = "dashed", col = "black") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hh.p, 
       file = file.path(figures, paste0(sp[i],": comparison of Head Height (Burress et al. 2017 dashed line)", ".png")), 
       width =100, height = 50, units = "cm")
}

#### Figures: difference in measurements for all species ----

## Standard Length
stats.sl <- stats.df %>%
  select(Species,
         b.SL,
         se.diff.SL_bbox,
         se.diff.SL_lm)

sl.diff.p <- ggplot(data = stats.sl, aes(x = se.diff.SL_lm)) +
  geom_density(col = "darkgoldenrod") +
  geom_rug(sides = "b", col = "darkgoldenrod") +
  ggtitle("Difference in Standard Length (Burress et al.) to Mean Standard Length (this paper) over Standard Error") + 
  scale_x_continuous(name = 'Standard Errors from Mean',
                     limits = c(-10, 30)) + 
  scale_y_continuous(name = 'Probability',
                     limits = c(0, .1)) + 
  geom_vline(xintercept = c(-3, 3), linetype = "dashed", col = "darkgray") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(sl.diff.p, 
       file = file.path(figures, paste0("se.diff.sl", ".png")), 
       width = 14, height = 10, units = "cm")

## Head Length
stats.hl <- stats.df %>%
  select(Species,
         b.HL,
         se.diff.HL_bbox,
         se.diff.HL_lm)

hl.diff.p <- ggplot(data = stats.hl, aes(x = se.diff.HL_lm)) +
  geom_density(col = "darkgoldenrod") +
  geom_rug(sides = "b", col = "darkgoldenrod") +
  ggtitle("Difference in Head Length (Burress et al.) to Mean Head Length (this paper) over Standard Error") + 
  scale_x_continuous(name = 'Standard Errors from Mean',
                     limits = c(-10, 30)) + 
  scale_y_continuous(name = 'Probability',
                     limits = c(0, .1)) + 
  geom_vline(xintercept = c(-3, 3), linetype = "dashed", col = "darkgray") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hl.diff.p, 
       file = file.path(figures, paste0("se.diff.hl", ".png")), 
       width = 14, height = 10, units = "cm")

## Head Height
stats.hh <- stats.df %>%
  select(Species,
         b.HD,
         se.diff.HH_lm)

hh.diff.p <- ggplot(data = stats.hh, aes(x = se.diff.HH_lm)) +
  geom_density(col = "darkgoldenrod") +
  geom_rug(sides = "b", col = "darkgoldenrod") +
  ggtitle("Difference in Head Height (Burress et al.) to Mean Head Height (this paper) over Standard Error") + 
  scale_x_continuous(name = 'Standard Errors from Mean',
                     limits = c(-5, 15)) + 
  scale_y_continuous(name = 'Probability',
                     limits = c(0, .2)) + 
  geom_vline(xintercept = c(-3, 3), linetype = "dashed", col = "darkgray") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hh.diff.p, 
       file = file.path(figures, paste0("se.diff.hh", ".png")), 
       width = 14, height = 10, units = "cm")

## Eye Diameter
stats.ed <- stats.df %>%
  select(Species,
         b.ED,
         se.diff.ED_bbox,
         se.diff.ED_lm)

ed.diff.p <- ggplot(data = stats.ed, aes(x = se.diff.ED_lm)) +
  geom_density(col = "darkgoldenrod") +
  geom_rug(sides = "b", col = "darkgoldenrod") +
  ggtitle("Difference in Eye Diameter (Burress et al.) to Mean Eye Diameter (this paper) over Standard Error") + 
  scale_x_continuous(name = 'Standard Errors from Mean',
                     limits = c(-10, 45)) + 
  scale_y_continuous(name = 'Probability',
                     limits = c(0, .05)) + 
  geom_vline(xintercept = c(-3, 3), linetype = "dashed", col = "darkgray") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(ed.diff.p, 
       file = file.path(figures, paste0("se.diff.ed", ".png")), 
       width = 14, height = 10, units = "cm")

## Pre-Orbital Depth
stats.pod <- stats.df %>%
  select(Species,
         b.SnL,
         se.diff.pOD_bbox,
         se.diff.pOD_lm)

pod.diff.p <- ggplot(data = stats.pod, aes(x = se.diff.pOD_lm)) +
  geom_density(col = "darkgoldenrod") +
  geom_rug(sides = "b", col = "darkgoldenrod") +
  ggtitle("Difference in Preorbital Depth (Burress et al.) to Mean Preorbital Depth (this paper) over Standard Error") + 
  scale_x_continuous(name = 'Standard Errors from Mean',
                     limits = c(-10, 35)) + 
  scale_y_continuous(name = 'Probability',
                     limits = c(0, .05)) + 
  geom_vline(xintercept = c(-3, 3), linetype = "dashed", col = "darkgray") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(pod.diff.p, 
       file = file.path(figures, paste0("se.diff.pod", ".png")), 
       width = 14, height = 10, units = "cm")
