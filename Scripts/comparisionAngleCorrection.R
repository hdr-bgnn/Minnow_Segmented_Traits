# comparison of measurement with the angle correction (morphology container 0.1.1)
# to without angle correction (morphology container 0.2.0)
# Meghan Balk 
# balk@battelleecology.org

## MAKE SURE WD IS IN REPO
#setwd("minnowTraits")

#### load dependencies ----
source("paths.R")
source("dependencies.R")

#### load functions ----
source(file.path(scripts, "json_df.R"))

# Files created by this script:
# 1. dataframe of old statistics

#### json to df ----
# files are the in the Presences folder
# get list of file names
m.0.1.1.files <- list.files(path = file.path("Morphology", "Measure_0.1.1"), pattern = '*.json')
m.0.2.0.files <- list.files(path = file.path("Morphology", "Measure_0.2.0"), pattern = '*.json')

# turn into csv
measure.0.1.1.df <- lapply(m.0.1.1.files, json_df) %>% #list of dataframes
  dplyr::bind_rows() #rbind to turn into single dataframes

measure.0.2.0.df <- lapply(m.0.2.0.files, json_df) %>% #list of dataframes
  dplyr::bind_rows() #rbind to turn into single dataframes

# merge with metadata file
meta.0.1.1.df <- merge(meta.df,measure.0.1.1.df, 
                       by.x = "original_file_name",
                       by.y = "base_name",
                       all.x = FALSE, all.y = TRUE)

meta.0.2.0.df <- merge(meta.df,measure.0.2.0.df, 
                       by.x = "original_file_name",
                       by.y = "base_name",
                       all.x = FALSE, all.y = TRUE)

# merge with Burress
names(b.df)[2:10] <- paste0("b.",names(b.df)[2:10])

b.0.1.1.df <- merge(b.df, measure.0.1.1.df,
                    by.x = "Species",
                    by.y = "scientific_name",
                    all.x = FALSE, all.y = TRUE)

b.0.2.0.df <- merge(b.df, measure.0.2.0.df,
                    by.x = "Species",
                    by.y = "scientific_name",
                    all.x = FALSE, all.y = TRUE)

stats_no_corr = b.0.1.1.df %>%
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
                   med.SL_lm = median(SL_lm.conv, na.rm = TRUE),
                   kurt.SL_lm = round(kurtosis(SL_lm.conv), digits = 2),
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
                   med.HL_bbox = median(HL_bbox.conv, na.rm = TRUE),
                   kurt.HL_bbox = round(kurtosis(HL_bbox.conv), digits = 2),
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
                   med.HL_lm = median(HL_lm.conv, na.rm = TRUE),
                   kurt.HL_lm = round(kurtosis(HL_lm.conv), digits = 2),
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
                   med.pOD_bbox = median(pOD_bbox.conv, na.rm = TRUE),
                   kurt.pOD_bbox = round(kurtosis(pOD_bbox.conv), digits = 2),
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
                   med.pOD_lm = median(pOD_lm.conv, na.rm = TRUE),
                   kurt.pOD_lm = round(kurtosis(pOD_lm.conv), digits = 2),
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
                   med.ED_bbox = median(ED_bbox.conv, na.rm = TRUE),
                   kurt.ED_bbox = round(kurtosis(ED_bbox.conv), digits = 2),
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
                   med.ED_lm = median(ED_lm.conv, na.rm = TRUE),
                   kurt.ED_lm = round(kurtosis(ED_lm.conv), digits = 2),
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
                   med.HH_lm = median(HH_lm.conv, na.rm = TRUE),
                   kurt.HH_lm = round(kurtosis(HH_lm.conv), digits = 2),
                   sd.HH_lm = sd(HH_lm.conv, na.rm = TRUE),
                   se.err.HH_lm = sd.HH_lm/sqrt(sample.size),
                   abs.se.diff.HH_lm = abs((b.HD - avg.HH_lm)/se.err.HH_lm),
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

write.csv(stats_no_corr,
          file = file.path(results, paste0("measurement_stats_0.1.1_", Sys.Date(), ".csv")),
          row.names = FALSE)

#### 2.0.0 stats ----

stats_corr = b.0.2.0.df %>%
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
                   med.SL_lm = median(SL_lm.conv, na.rm = TRUE),
                   kurt.SL_lm = round(kurtosis(SL_lm.conv), digits = 2),
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
                   med.HL_bbox = median(HL_bbox.conv, na.rm = TRUE),
                   kurt.HL_bbox = round(kurtosis(HL_bbox.conv), digits = 2),
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
                   med.HL_lm = median(HL_lm.conv, na.rm = TRUE),
                   kurt.HL_lm = round(kurtosis(HL_lm.conv), digits = 2),
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
                   med.pOD_bbox = median(pOD_bbox.conv, na.rm = TRUE),
                   kurt.pOD_bbox = round(kurtosis(pOD_bbox.conv), digits = 2),
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
                   med.pOD_lm = median(pOD_lm.conv, na.rm = TRUE),
                   kurt.pOD_lm = round(kurtosis(pOD_lm.conv), digits = 2),
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
                   med.ED_bbox = median(ED_bbox.conv, na.rm = TRUE),
                   kurt.ED_bbox = round(kurtosis(ED_bbox.conv), digits = 2),
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
                   med.ED_lm = median(ED_lm.conv, na.rm = TRUE),
                   kurt.ED_lm = round(kurtosis(ED_lm.conv), digits = 2),
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
                   med.HH_lm = median(HH_lm.conv, na.rm = TRUE),
                   kurt.HH_lm = round(kurtosis(HH_lm.conv), digits = 2),
                   sd.HH_lm = sd(HH_lm.conv, na.rm = TRUE),
                   se.err.HH_lm = sd.HH_lm/sqrt(sample.size),
                   abs.se.diff.HH_lm = abs((b.HD - avg.HH_lm)/se.err.HH_lm),
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