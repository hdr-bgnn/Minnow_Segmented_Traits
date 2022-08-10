# function for turning json files to dataframes
# Meghan Balk 
# balk@battelleecology.org

#turn into data frame
json_df <- function(jfile){
  input <- fromJSON(file = jfile, unexpected.escape = "keep")
  df <- as.data.frame(input)
  if(isTRUE(names(df) %in% "scale")){
    df$scale <- as.numeric(df$scale) #for some reason there are "doubles"; making them all the same
  }
  #will get warnings because NA are created since some df$scales are characters ("none")
  return(df)
}


### old code
# json_df <- function(jfile){
#   input <- fromJSON(file = jfile, unexpected.escape = "keep")
#   #some json files have null for scale (index 15 & 16)
#   if(isTRUE(is.null(input[15][[1]][[1]]))){
#     input[15][[1]][[1]] <- "none"
#   }
#   if(isTRUE(is.null(input[16][[1]][[1]]))){
#     input[16][[1]][[1]] <- "none"
#   }
#   df <- as.data.frame(input)
#   df$file.name <- gsub(jfile,
#                        pattern = "_measure.json", #can change this depending on the file name
#                        replacement = "")
#   return(df)
# }
