# selection of the segmented images for analyses
# Meghan Balk 
# balk@battelleecology.org

library(rjson)

#get list of file names
files <- list.files(pattern = '*.json')

#turn into csv
#rbind
combo <- lapply(files, as.data.frame(fromJSON)) %>% bind_rows()
#test
lapply("INHS_FISH_003752_presence.json", as.data.frame(fromJSON)) %>% bind_rows()

go thorugh all files
open into json
compile into one json file
then export into csv

https://www.tutorialspoint.com/r/r_json_files.htm

#post-processing code
create tools notebook in OSC

clone repo onto OSC and open jupyter notebook there
on daashboard go to jupyter notebook and launch; create jupyter notebook folder w folder
change kernel and configure w R

go to active job

when writing code, can test if import is empty or not


for analyses: 
  - % blob by trait and then by sp
  - create coefficient of variation