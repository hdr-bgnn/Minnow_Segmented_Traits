# selection of the segmented images for analyses
# Meghan Balk
# balk@battelleecology.org
library(dplyr)
library(ggplot2)
library(reshape2)
source("Scripts/init.R")

sampling.df <- read.csv(file = sampling_path, header = TRUE)

# Files created by this script:
# 1. presence absence matrix from the folder "Presence"
# 2. must have ruler
# 3. new data set that only keeps images that have at least 95% for
#    the biggest blob for trunk, eye, and head
# 4. table of the sample size for species in Burress et al. that have 95% blob
#    for the trunk, eye, and head
# 5. table of sampling as selection criteria applied
# 6. heat map of the average blob size of the largest blob for each trait per species
# 7. heat map of the sd of blob sizes of the largest blob for each trait per species
# 8. plot of distribution of sample size (number of images) per species that have
#    at least 95% blob for trunk, eye, head

#### json to df ----
# files are the in the Presences folder
# get list of file names
p.files <- list.files(path = presence, pattern = '*.json', full.names=TRUE)

# turn into csv
presence.df <- lapply(p.files, json_df, type = "_presence") %>%
  dplyr::bind_rows() # collapses list of data frames into a single data frame

#column names have a mix of "_" and ".", standardize to all being "_"
names(presence.df) <- gsub(x = names(presence.df),
                           pattern = "\\.",
                           replacement = "_")

# write data frame to Results directory

write.csv(presence.df,
          file = presence_absence_matrix_path,
          row.names = FALSE) #no index

#### merge with metadata ----
#combine with metadata to get taxonomic hierarchy
colnames(mm.df) #loaded in from paths.R

presence.meta <- merge(presence.df, mm.df,
                       by.x = "base_name",
                       by.y = "ARKID",
                       all.x = TRUE,
                       all.y = FALSE)

colnames(presence.meta)[colnames(presence.meta) == 'base_name'] <- 'ARKID'

#### 4. sampling after segmentation ----

sampling.df$Selection_Criteria[4] <- "After segmentation"

#check df (need to re-run w everything)
nrow(presence.meta) #284
length(unique(presence.meta$scientificName)) #4

sampling.df$All_Minnows_Images_sp[4] <- paste0(nrow(presence.meta),
                                               " (",
                                               length(unique(presence.meta$scientificName)),
                                               ")")

#compare to Burress et al. 2017
nrow(presence.meta[presence.meta$scientificName %in% b.sp,]) #9
length(unique(presence.meta$scientificName[presence.meta$scientificName %in% b.sp])) #3

sampling.df$Burress_et_al._2017_Overlap_Images_sp[4] <- paste0(nrow(presence.meta[presence.meta$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(presence.meta$scientificName[presence.meta$scientificName %in% b.sp])),
                                                               ")")
## 5. remove images that don't have a scale ----

sampling.df$Selection_Criteria[5] <- "Has ruler scale"

unique(presence.meta$ruler_unit) #None means no scale was detected or extracted
errors <- presence.meta[presence.meta$ruler_unit == "None",] %>% tidyr::drop_na(ruler_unit)
nrow(errors) #11 images

write.csv(errors,
          file = file.path(results, "df.missing.scale.csv"),
          row.names = FALSE)

presence.meta.scale <- presence.meta[!(presence.meta$ARKID %in% errors$ARKID),]

sampling.df$All_Minnows_Images_sp[5] <- paste0(nrow(presence.meta.scale),
                                               " (",
                                               length(unique(presence.meta.scale$scientificName)),
                                               ")")

#compare to Burress et al. 2017
nrow(presence.meta.scale[presence.meta.scale$scientificName %in% b.sp,]) #9
length(unique(presence.meta.scale$scientificName[presence.meta.scale$scientificName %in% b.sp])) #3

sampling.df$Burress_et_al._2017_Overlap_Images_sp[5] <- paste0(nrow(presence.meta.scale[presence.meta.scale$scientificName %in% b.sp,]),
                                                               " (",
                                                               length(unique(presence.meta.scale$scientificName[presence.meta.scale$scientificName %in% b.sp])),
                                                               ")")

write.csv(presence.meta.scale,
          file = file.path(results, "df.errors.removed.csv"),
          row.names = FALSE)

#### analyze presence ----

#get rid of columns we don't need
#not using adipose fin for minnows
#not using fin rays for minnows
#not using information about dimensions of the image
df <- select(presence.meta.scale, - c("adipos_fin_number", "adipos_fin_percentage",
                                      "caudal_fin_ray_number", "caudal_fin_ray_percentage",
                                      "alt_fin_ray_number", "alt_fin_ray_percentage"))

## how many 0s are there? ====
no.abs <- df[apply(df, 1, function(row) all(row !=0 )), ]  # Remove zero-rows
nrow(df) - nrow(no.abs) #6

## how many have all fins? ====
df.fin.per <- select(df, c("scientificName", contains("percentage")))
df.fin.per$total <- rowSums(df.fin.per[ , 2:9], na.rm=TRUE)
nrow(df.fin.per[df.fin.per$total > 8,]) #none are perfect

#### 6. sampling of data ----
df.fin.per.sample <- df.fin.per %>%
  group_by(scientificName) %>%
  summarize(sample = n()) %>%
  as.data.frame()

sampling.df$Selection_Criteria[6] <- "All Traits Present"

sampling.df$All_Minnows_Images_sp[6] <- paste0(sum(df.fin.per.sample$sample),
                                               " (",
                                               length(unique(df.fin.per.sample$scientificName)),
                                               ")")

# compare to burress
nrow(df.fin.per.sample[df.fin.per.sample$scientificName %in% b.sp,]) #
length(unique(df.fin.per.sample$scientificName[df.fin.per.sample$scientificName %in% b.sp])) #

sampling.df$Burress_et_al._2017_Overlap_Images_sp[6] <- paste0(sum(df.fin.per.sample$sample[df.fin.per.sample$scientificName %in% b.sp]),
                                                                " (",
                                                                length(unique(df.fin.per.sample$scientificName[df.fin.per.sample$scientificName %in% b.sp])),
                                                                ")")

#### visualize sampling data ----
df.fin.per.sample.dist <- ggplot(data = df.fin.per.sample, aes(x = sample)) +
  geom_density(col = "blue") +
  geom_rug(sides = "b", col = "blue") +
  ggtitle("Distribution of sampling per species") +
  scale_x_continuous(breaks = c(seq(0, 1000, 50)),
                     name = 'Sample Size') +
  scale_y_continuous(name = 'Density') +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(df.fin.per.sample.dist,
       file = presence_absence_dist_path,
       width = 20, height = 15, units = "cm")

#### statistics about the data ----

## fins ====
stats <- df %>%
  summarise(min.head = min(head_percentage),
            max.head = max(head_percentage),
            avg.head = mean(head_percentage),
            sd.head = sd(head_percentage),
            min.eye = min(eye_percentage),
            max.eye = max(eye_percentage),
            avg.eye = mean(eye_percentage),
            sd.eye = sd(eye_percentage),
            min.trunk = min(trunk_percentage),
            max.trunk = max(trunk_percentage),
            avg.trunk = mean(trunk_percentage),
            sd.trunk = sd(trunk_percentage),
            min.dor = min(dorsal_fin_percentage),
            max.dor = max(dorsal_fin_percentage),
            avg.dor = mean(dorsal_fin_percentage),
            sd.dor = sd(dorsal_fin_percentage),
            min.caud = min(caudal_fin_percentage),
            max.caud = max(caudal_fin_percentage),
            avg.caud = mean(caudal_fin_percentage),
            sd.caud = sd(caudal_fin_percentage),
            min.anal = min(anal_fin_percentage),
            max.anal = max(anal_fin_percentage),
            avg.anal = mean(anal_fin_percentage),
            sd.anal = sd(anal_fin_percentage),
            min.pelv = min(pelvic_fin_percentage),
            max.pelv = max(pelvic_fin_percentage),
            avg.pelv = mean(pelvic_fin_percentage),
            sd.pelv = sd(pelvic_fin_percentage),
            min.pect = min(pectoral_fin_percentage),
            max.pect = max(pectoral_fin_percentage),
            avg.pect = mean(pectoral_fin_percentage),
            sd.pect = sd(pectoral_fin_percentage))

## fins by species ====
stats.sp <- df %>%
  group_by(scientificName) %>%
  summarise(sample = n(),
            min.head = min(head_percentage),
            max.head = max(head_percentage),
            avg.head = mean(head_percentage),
            sd.head = sd(head_percentage),
            min.eye = min(eye_percentage),
            max.eye = max(eye_percentage),
            avg.eye = mean(eye_percentage),
            sd.eye = sd(eye_percentage),
            min.trunk = min(trunk_percentage),
            max.trunk = max(trunk_percentage),
            avg.trunk = mean(trunk_percentage),
            sd.trunk = sd(trunk_percentage),
            min.dor = min(dorsal_fin_percentage),
            max.dor = max(dorsal_fin_percentage),
            avg.dor = mean(dorsal_fin_percentage),
            sd.dor = sd(dorsal_fin_percentage),
            min.caud = min(caudal_fin_percentage),
            max.caud = max(caudal_fin_percentage),
            avg.caud = mean(caudal_fin_percentage),
            sd.caud = sd(caudal_fin_percentage),
            min.anal = min(anal_fin_percentage),
            max.anal = max(anal_fin_percentage),
            avg.anal = mean(anal_fin_percentage),
            sd.anal = sd(anal_fin_percentage),
            min.pelv = min(pelvic_fin_percentage),
            max.pelv = max(pelvic_fin_percentage),
            avg.pelv = mean(pelvic_fin_percentage),
            sd.pelv = sd(pelvic_fin_percentage),
            min.pect = min(pectoral_fin_percentage),
            max.pect = max(pectoral_fin_percentage),
            avg.pect = mean(pectoral_fin_percentage),
            sd.pect = sd(pectoral_fin_percentage)) %>%
  as.data.frame()

#### Heat Map ----

#need to have matrix in the order we already want
#need to label rows
stats.sp.sort <- stats.sp[order(stats.sp$sample, decreasing = TRUE),]
row.names(stats.sp.sort) <- paste(stats.sp.sort$scientificName, " (", stats.sp.sort$sample, ")", sep = "")
#head, eye, trunk, dorsal, caudal, anal, pelvic, pectoral
colnames(stats.sp.sort) #these are in the correct order

#all stats
stats.sp.trim <- stats.sp[,-c(1:2)]
stats.sp.trim <- as.matrix(stats.sp.trim)

## average ====
stats.sp.avg <- select(stats.sp.sort, contains("avg."))
colnames(stats.sp.avg) #in correct order
stats.sp.avg <- as.matrix(stats.sp.avg)

melt_stats_avg <- melt(stats.sp.avg)
head(melt_stats_avg)

hm.avg <- ggplot(melt_stats_avg, aes(Var2, Var1)) +
  geom_tile(aes(fill = value), color = "white") +
  scale_fill_gradient(low = "#FFFFCC", high = "#800026") +
  labs( x = "Trait",
        y = "Species (n)",
        title = "Heat Map of Average % of Biggest Blob") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hm.avg,
       file = heatmap_avg_blob_path,
       width = 14, height = 20, units = "cm")

min(melt_stats_avg$value) #81 is smallest average size

## sd ====
stats.sp.sd <- select(stats.sp.sort, contains("sd."))
stats.sp.sd <- as.matrix(stats.sp.sd)
colnames(stats.sp.sd) #in correct order

melt_stats_sd <- melt(stats.sp.sd)
head(melt_stats_sd)
melt_stats_sd.na <- melt_stats_sd %>% 
  tidyr::drop_na(value)

hm.sd <- ggplot(melt_stats_sd.na, aes(Var2, Var1)) +
  geom_tile(aes(fill = value), color = "white") +
  scale_fill_gradient(low = "#FFFFCC", high = "#800026") +
  labs( x = "Trait",
        y = "Species (n)",
        title = "Heat Map of Standard Deviation % of Biggest Blob") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hm.sd,
       file = heatmap_sd_blob_path,
       width = 14, height = 20, units = "cm")

max(melt_stats_sd$value, na.rm = TRUE) #0.58 largest standard deviation

#a lot of species are missing fins, like dorsal, anal, pelvic, pectoral
#caudal, eye, trunk perform the best

#for analyses:
#  - % blob by trait and then by sp
#  - create coefficient of variation

#### remove species missing traits ----
#remove species that have 0 for traits we are using: head, eye, trunk
df.fin.0 <- df.fin.per[df.fin.per$head_percentage > 0 &
                       df.fin.per$eye_percentage > 0 &
                       df.fin.per$trunk_percentage > 0,]

nrow(df.fin.per) #6297
nrow(df.fin.0) #6297, no loss

## 7. 95% min for blob ====

sampling.df$Selection_Criteria[7] <- "95% blobb for head, eye, trunk"

#based on visualizations above, we decided to keep .95 blobs; only for the traits we care about
df.fin.95.3 <- df.fin.per[df.fin.per$head_percentage > .95 &
                          df.fin.per$eye_percentage > .95 &
                          df.fin.per$trunk_percentage > .95,]
nrow(df.fin.95.3) #6205 images
length(unique(df.fin.95.3$scientificName)) #41 species

sampling.df$All_Minnows_Images_sp[7] <- paste0(nrow(df.fin.95.3),
                                               " (",
                                               length(unique(df.fin.95.3$scientificName)),
                                               ")")

## compare to Burress et al. 2017
df.fin.b.95.3 <- df.fin.95.3[df.fin.95.3$scientificName %in% b.sp,]
nrow(df.fin.b.95.3) #445
length(unique(df.fin.b.95.3$scientificName)) #8

sampling.df$Burress_et_al._2017_Overlap_Images_sp[7] <- paste0(nrow(df.fin.b.95.3),
                                                               " (",
                                                               length(unique(df.fin.b.95.3$scientificName)),
                                                               ")")

#how is the sampling for these species?
b.sampling <- as.data.frame(table(df.fin.b.95.3$scientificName))
colnames(b.sampling) <- c("Scientific_Name", "Sample_Size")
write.csv(b.sampling,
          file = sampling_species_burress_path,
          row.names = FALSE)

## how much does the total dataset get reduced if all traits are at a 95% cut off?
df.fin.95 <- df.fin.per[df.fin.per$head_percentage > .95 &
                        df.fin.per$eye_percentage > .95 &
                        df.fin.per$trunk_percentage > .95 &
                        df.fin.per$dorsal_fin_percentage > .95 &
                        df.fin.per$caudal_fin_percentage > .95 &
                        df.fin.per$anal_fin_percentage > .95 &
                        df.fin.per$pelvic_fin_percentage > .95 &
                        df.fin.per$pectoral_fin_percentage > .95,]
nrow(df.fin.95) #4663
length(unique(df.fin.95$scientificName)) #41

sort(table(df.fin.95$scientificName)) #3 species have under 10 samples; lose 20 images

## how much does the total dataset get reduced for the 3 segmented traits at a 95% cut off?
df.fin.95.3 <- df.fin.per[df.fin.per$head_percentage > .95 &
                          df.fin.per$eye_percentage > .95 &
                          df.fin.per$trunk_percentage > .95,]
nrow(df.fin.95.3) #6205; a lot more!
length(unique(df.fin.95.3$scientificName)) #41

# how is sampling?
sampling.95.3 <- as.data.frame(sort(table(df.fin.95.3$scientificName)))
colnames(sampling.95.3) <- c("Scientific_Name", "Sample_Size")
nrow(sampling.95.3) #41 sp; don't lose any!

write.csv(sampling.95.3,
          file = sampling_minnows_seg_path,
          row.names = FALSE)

write.csv(sampling.df,
          file = sampling_df_seg_path,
          row.names = FALSE)
