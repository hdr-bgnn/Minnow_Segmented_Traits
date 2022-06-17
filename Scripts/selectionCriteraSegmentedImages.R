# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)

#get list of file names
files <- list.files(pattern = '*.json')

#turn into csv
#rbind

json_df <- function(jfile){
  input <- fromJSON(file = jfile)
  df <- as.data.frame(input)
  return(df)
}

#test with one  file
test <- json_df(jfile = "INHS_FISH_003752_presence.json")
str(test)

presence.df <- lapply(files, json_df) %>% bind_rows()

#test that it is the same as Thibault
#Thibault used the following images: 62362, 99358, 103219, 106768, 47892, 25022, 24324, 56883, 43105, 95766
tt.df <- read.csv("https://raw.githubusercontent.com/hdr-bgnn/minnowTraits/main/Jupyter_Notebook/output.csv",
                  header = TRUE)

#differences in outputs....
tt.df <- tt.df[,-1]
names(presence.df) <- gsub(x = names(presence.df), pattern = "\\.", replacement = "_")  

colnames(tt.df)
colnames(presence.df)
setdiff(colnames(tt.df), colnames(presence.df))
setdiff(tt.df, presence.df)

write.csv(presence.df, "presence.absence.matrix.csv", row.names = FALSE)


#for analyses: 
#  - % blob by trait and then by sp
#  - create coefficient of variation