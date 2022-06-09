chunkData <- function(
    df, #dataframe to be chunked into parts
    start, #beginning of index
    end) #ending of index
  {
  chunk <- df[start:end,]
  write.csv(chunk, 
            file=paste(deparse(substitute(df)), end, "csv", sep = "."),
            row.names = FALSE)
}
