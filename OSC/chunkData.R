df <- read.csv(minnows)

chunkData <- function(
    df, #dataframe to be chunked into parts
    start, #beginning of index
    end) #ending of index
  {
  chunk <- df[start:end,]
  write.csv(paste(df, start, end, sept = "."))
}


#output csv