# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

revn::init()

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

#column names have a mix of "_" and ".", standardize to all being "_"
names(presence.df) <- gsub(x = names(presence.df), 
                           pattern = "\\.", 
                           replacement = "_")  


#write dataframe to Files directory
#return to GitHub directory
setwd("GitHub/BGNN/minnowTraits/Files")
write.csv(presence.df, "presence.absence.matrix.csv", row.names = FALSE)

#read presence absence dataframe
presence.df <- read.csv("presence.absence.matrix.csv", 
                        header = TRUE)

#combine with metadata to get taxonomic hierarchy
meta.df <- read.csv("Image_Metadata_v1_20211206_151152.csv", header = TRUE)
colnames(meta.df)
#remove ".jpg" from file name to more easily align with file name in presence.df
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
#not using adipose fin for minnows
#not using fin rays for minnows
#not using information about dimensions of the image
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

#sampling of data
df.fin.per.sample <- df.fin.per %>%
  group_by(scientific_name) %>%
  summarize(sample = n()) %>%
  as.data.frame()

#visualize sampling data
df.fin.per.sample.dist <- ggplot(data = df.fin.per.sample, aes(x = sample)) +
  geom_density(col = "blue") +
  geom_rug(sides = "b", col = "blue") +
  ggtitle("Distribution of sampling per species") +
  scale_x_continuous(breaks = c(seq(0, 1000, 50)),
                     name = 'Sample Size') + 
  scale_y_continuous(name = 'Density') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(df.fin.per.sample.dist, file = "presence.absence.sample.dist.png", 
       width = 20, height = 15, units = "cm",
       path = "../Prelim Results/")

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

ggsave(hm.avg, file = "heatmap.avg.blob.png", 
       width = 14, height = 20, units = "cm",
       path = "../Prelim Results/")

min(melt_stats_avg$value) #81 is smallest average size

#sd
stats.sp.sd <- select(stats.sp.sort, contains("sd."))
stats.sp.sd <- as.matrix(stats.sp.sd)
colnames(stats.sp.sd) #in correct order

melt_stats_sd <- melt(stats.sp.sd)
head(melt_stats_sd)

hm.sd <- ggplot(melt_stats_avg, aes(Var2, Var1)) +
  geom_tile(aes(fill = value), color = "white") +
  scale_fill_gradient(low = "#FFFFCC", high = "#800026") + 
  labs( x = "Trait", 
        y = "Species (n)",
        title = "Heat Map of Standard Deviation % of Biggest Blob") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

ggsave(hm.avg, file = "heatmap.sd.blob.png", 
       width = 14, height = 20, units = "cm",
       path = "../Prelim Results/")

max(melt_stats_sd$value) #.34 largest standard deviation

#a lot of species are missing fins, like dorsal, anal, pelvic, pectoral
#caudal, eye, trunk perform the best

#for analyses: 
#  - % blob by trait and then by sp
#  - create coefficient of variation

ggplot(data = presence.meta) +
  geom_density(aes(x = dorsal_fin_percentage, fill = scientific_name))



#remove species that have 0 for traits we are using: head, eye, trunk
df.fin.0 <- df.fin.per[df.fin.per$head_percentage > 0 &
                       df.fin.per$eye_percentage > 0 &
                       df.fin.per$trunk_percentage > 0,]

nrow(df.fin.per) #6297
nrow(df.fin.0) #6297, no loss

#reduce to species in Burress et al paper
burress <- read.csv("Previous Fish Measurements - Burress et al. 2016.csv", header = TRUE)
b.sp <- unique(burress$Species)

df.fin.burress <- df.fin.0[df.fin.0$scientific_name %in% b.sp,]
nrow(df.fin.burress) #446

#based on visualizations above, we decided to keep .95 blobs; only for the traits we care about
df.fin.b.95 <- df.fin.burress[df.fin.burress$head_percentage > .95 &
                              df.fin.burress$eye_percentage > .95 &
                              df.fin.burress$trunk_percentage > .95,]
nrow(df.fin.b.95) #445 images
length(unique(df.fin.b.95$scientific_name)) #8 species

#how is the sampling for these species?
b.sampling <- as.data.frame(table(df.fin.b.95$scientific_name))
colnames(b.sampling) <- c("Scientific_Name", "Sample_Size")
write.csv(b.sampling, "sampling.species.in.Burress.csv", row.names = FALSE)

##how much does the total dataset get reduced if all traits are at a 95% cut off?
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

sort(table(df.fin.95$scientific_name)) #3 species have under 10 samples; lose 20 images

##how much does the total dataset get reduced for the 3 segmented traits at a 95% cut off?
df.fin.95.3 <- df.fin.per[df.fin.per$head_percentage > .95 &
                          df.fin.per$eye_percentage > .95 &
                          df.fin.per$trunk_percentage > .95,]
nrow(df.fin.95.3) #6205; a lot more!
length(unique(df.fin.95.3$scientific_name)) #41

#how is sampling?
sampling.95.3 <- as.data.frame(sort(table(df.fin.95.3$scientific_name)))
colnames(sampling.95.3) <- c("Scientific_Name", "Sample_Size")
nrow(sampling.95) #41 sp; don't lose any!
write.csv(sampling.95.3, "sampling.minnows.95.blob.3.segments.csv", row.names = FALSE)
