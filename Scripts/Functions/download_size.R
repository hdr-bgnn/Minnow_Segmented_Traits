#from stack overflow: https://stackoverflow__com.teameo.ca/questions/63852146/how-to-determine-online-file-size-before-download-in-r
download_size <- function(url){
  as.numeric(httr::HEAD(url)$headers$`content-length`)
}