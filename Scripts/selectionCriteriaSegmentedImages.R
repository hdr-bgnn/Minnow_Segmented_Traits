# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)
library(tidyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(reshape2)

#get list of file names
#path is in the OSC 
setwd("/fs/ess/PAS2136/BGNN/Minnows/Morphology/Presence/")
files <- list.files(pattern = '*.json')

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile)
  df <- as.data.frame(input)
  df$file.name <- gsub(jfile,
                       pattern = "_presence.json", 
                       replacement = "")
  return(df)
}

#test with one  file
test.file <- "INHS_FISH_003752_presence.json"
test <- json_df(jfile = test.file)
str(test)

presence.df <- lapply(files, json_df) %>% 
  dplyr::bind_rows()

names(presence.df) <- gsub(x = names(presence.df), 
                           pattern = "\\.", 
                           replacement = "_")  

#test that it is the same as Thibault
#Thibault used the following images: 62362, 99358, 103219, 106768, 47892, 25022, 24324, 56883, 43105, 95766
tt.df <- read.csv("https://raw.githubusercontent.com/hdr-bgnn/minnowTraits/main/Jupyter_Notebook/output.csv",
                  header = TRUE)

#differences in outputs....
colnames(tt.df)[colnames(tt.df) == "X"] <- "file_name"

colnames(tt.df)
colnames(presence.df)
setdiff(colnames(tt.df), colnames(presence.df))

#return to GitHub directory
setwd("/users/PAS2136/balkm/minnowTraits/Files")

write.csv(presence.df, "presence.absence.matrix.csv", row.names = FALSE)

presence.df <- read.csv("/users/PAS2136/balkm/minnowTraits/Files/presence.absence.matrix.csv", 
                        header = TRUE)

names(presence.df) <- gsub(x = names(presence.df), 
                           pattern = "\\.", 
                           replacement = "_")  

#combine with metadata to get taxonomic heirarchy
meta.df <- read.csv("/users/PAS2136/balkm/minnowTraits/Files/Image_Metadata_v1_20211206_151152.csv", header = TRUE)
colnames(meta.df)
meta.df$original_file_name <- gsub(meta.df$original_file_name,
                                   pattern = ".jpg",
                                   replacement = "")

presence.meta <- merge(presence.df, meta.df, 
                       by.x = "file_name", by.y = "original_file_name", 
                       all.x = TRUE, all.y = FALSE)
#check df
nrow(presence.meta)
length(unique(presence.meta$scientific_name))

#get rid of columns we don't need
df <- select(presence.meta, - c("adipos_fin_number", "adipos_fin_percentage",
                                "caudal_fin_ray_number", "caudal_fin_ray_percentage",
                                "alt_fin_ray_number", "alt_fin_ray_percentage",
                                "width", "size", "height"))

## how many 0s are there?
no.abs <- df[apply(df, 1, function(row) all(row !=0 )), ]  # Remove zero-rows
nrow(df) - nrow(no.abs) #40

## how many have all fins?
df.fin.per <- select(df, c("scientific_name", contains("percentage")))
df.fin.per$total <- rowSums(df.fin.per[ , 2:9], na.rm=TRUE)
nrow(df.fin.per[df.fin.per$total > 8,]) #none are perfect

## how many have fins with an 85% blob?
df.fin.85 <- df.fin.per[df.fin.per$head_percentage > .85 &
                        df.fin.per$eye_percentage > .85 &
                        df.fin.per$trunk_percentage > .85 &
                        df.fin.per$dorsal_fin_percentage > .85 &
                        df.fin.per$caudal_fin_percentage > .85 &
                        df.fin.per$anal_fin_percentage > .85 &
                        df.fin.per$pelvic_fin_percentage > .85 &
                        df.fin.per$pectoral_fin_percentage > .85,]
nrow(df.fin.85) #5026
length(unique(df.fin.85$scientific_name)) #41
#how many images per species
df.fin.85.samp <- df.fin.85 %>%
  group_by(scientific_name) %>%
  summarise(sample = n())

nrow(df.fin.85.samp[df.fin.85.samp$sample >= 10,]) #39
keep.10 <- df.fin.85.samp$scientific_name[df.fin.85.samp$sample >= 10]

df.fin.85.trim <- df.fin.85[df.fin.85$scientific_name %in% keep.10,]
nrow(df.fin.85.trim) #5009

#.95 
df.fin.95 <- df.fin.per[df.fin.per$head_percentage > .95 &
                        df.fin.per$eye_percentage > .95 &
                        df.fin.per$trunk_percentage > .95 &
                        df.fin.per$dorsal_fin_percentage > .95 &
                        df.fin.per$caudal_fin_percentage > .95 &
                        df.fin.per$anal_fin_percentage > .95 &
                        df.fin.per$pelvic_fin_percentage > .95 &
                        df.fin.per$pectoral_fin_percentage > .95,]
nrow(df.fin.95) #4663

length(unique(df.fin.95$scientific_name)) #41
#how many images per species
df.fin.95.samp <- df.fin.95 %>%
  group_by(scientific_name) %>%
  summarise(sample = n())

nrow(df.fin.95.samp[df.fin.95.samp$sample >= 10,]) #39


#visualize remaining data
setwd("/users/PAS2136/balkm/minnowTraits/Prelim Results/")

df.fin.95.samp.trim <- df.fin.95.samp[df.fin.95.samp$sample >= 10,] %>% as.data.frame()
df.fin.95.samp.dist <- ggplot(data = df.fin.95.samp.trim, aes(x = sample)) +
  geom_density(col = "blue") +
  geom_rug(sides = "b", col = "blue") +
  ggtitle("Distribution of sampling per species") +
  scale_x_continuous(breaks = c(seq(0, 1000, 50)),
                     name = 'Sample Size') + 
  scale_y_continuous(name = 'Density') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(df.fin.95.samp.dist, file = "df.fin.95.samp.dist.png", width = 14, height = 20, units = "cm")

#about the data
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
#most percentages are between .8 adn 1
#only caudal fin is low (0.45 as the smallest blob)

stats.sp <- df %>%
  group_by(scientific_name) %>%
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

#make a heat map
#need to have matrix in the order we already want
#need to label rows
stats.sp.sort <- stats.sp[order(stats.sp$sample, decreasing = TRUE),]
row.names(stats.sp.sort) <- paste(stats.sp.sort$scientific_name, " (", stats.sp.sort$sample, ")", sep = "")
#head, eye, trunk, dorsal, caudal, anal, pelvic, pectoral
colnames(stats.sp.sort) #these are in the correct order

#all stats
stats.sp.trim <- stats.sp[,-c(1:2)]
stats.sp.trim <- as.matrix(stats.sp.trim)

hm <- heatmap(stats.sp.trim, 
              labRow = rownames(stats.sp.trim),
              labCol = colnames(stats.sp.trim), 
              main = "Heat Map")

#average
stats.sp.avg <- select(stats.sp.sort, contains("avg."))
colnames(stats.sp.avg) #in correct order
stats.sp.avg <- as.matrix(stats.sp.avg)

# min(stats.sp.avg) #smallest % is 81.5%
# #coloring scheme #yellow to red
# my_colors <- colorRampPalette(c("#FFFFCC", "#800026"))
# #pal <- colorRampPalette(brewer.pal(9, "YlOrRd"))(5)
# length(seq(.8, 1, .05)) #want 5 colors
# 
# hm.avg <- heatmap(stats.sp.avg,
#                   labRow = rownames(stats.sp.avg),
#                   labCol = colnames(stats.sp.avg),
#                   Rowv = NA, Colv = NA, #no dendrograms
#                   col = my_colors(5),
#                   #breaks = color_breaks,
#                   margins = c(5, 10),
#                   main = "Heat Map of Average % of Biggest Blob")
# legend(x = "right", 
#        legend = c("0.80", "0.85", "0.90", "0.95", "1.00"),
#        fill = my_colors(5))

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

ggsave(hm.avg, file = "heatmap.avg.blob.png", width = 14, height = 20, units = "cm")

#sd
stats.sp.sd <- select(stats.sp.sort, contains("sd."))
stats.sp.sd <- as.matrix(stats.sp.sd)
colnames(stats.sp.sd) #in correct order


# min(stats.sp.sd) #smallest 0
# max(stats.sp.sd) #max is 0.34
# #coloring scheme #yellow to red
# my_colors <- colorRampPalette(c("#FFFFCC", "#800026"))
# #pal <- colorRampPalette(brewer.pal(9, "YlOrRd"))
# length(seq(0, 0.35, .05)) #want 8 colors
# 
# hm.sd <- heatmap(stats.sp.sd,
#                   labRow = rownames(stats.sp.sd),
#                   labCol = colnames(stats.sp.sd),
#                   Rowv = NA, Colv = NA, #no dendrograms
#                   col = my_colors(8),
#                   margins = c(5, 10),
#                   main = "Heat Map of Standard Deviation % of Blobs")
# legend(x = "right", 
#        legend = c("0.00", "0.05", "0.10", "0.15", "0.20", "0.25", "0.30", "0.35"),
#        fill = my_colors(8))


melt_stats_sd <- melt(stats.sp.sd)
head(melt_stats_sd)

hm.asd <- ggplot(melt_stats_avg, aes(Var2, Var1)) +
  geom_tile(aes(fill = value), color = "white") +
  scale_fill_gradient(low = "#FFFFCC", high = "#800026") + 
  labs( x = "Trait", 
        y = "Species (n)",
        title = "Heat Map of Standard Deviation % of Biggest Blob") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hm.avg, file = "heatmap.sd.blob.png", width = 14, height = 20, units = "cm")


stats.sp$min.caud #only see four small numbers
small.num.caud <- sort(stats.sp$min.caud, decreasing = FALSE)
smallest.caud <- small.num.caud[1:4]
stats.sp[stats.sp$min.caud %in% smallest.caud,]
#N. atherinoides, N. boops, N. heterodon, N. texanus
#sample sizes vary wildly (in order): 610, 188, 31, 97
#also have other small %

#a lot of species are missing fins, like dorsal, anal, pelvic, pectoral
#caudal, eye, trunk perform the best

nrow(presence.meta[presence.meta$dorsal_fin_percentage == 0,]) #13


#for analyses: 
#  - % blob by trait and then by sp
#  - create coefficient of variation

ggplot(data = presence.meta) +
  geom_density(aes(x = dorsal_fin_percentage, fill = scientific_name))
