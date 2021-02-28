library(dplyr)
args <- commandArgs(trailingOnly=TRUE)
json.gen.dir <- function(dir, type, filter.exp = NA, debug = F) {
  files <- Sys.glob(paste0(dir, "/*")) %>% basename()
  files <- files[!grepl(".json", files)]
  if (!is.na(filter.exp))
    files <- files[grepl(filter.exp, files)]

  jsongen <- lapply(files, function(x) {
    return(list(name = x,
                url = x,
                type = type))
  })
  json <- jsongen %>% jsonlite::toJSON(auto_unbox = T)  %>% jsonlite::prettify()
  write(json, paste0(dir, "/files.json"))
  if (debug == T)
    return(json)
  else
    return()
}


json.gen.dir(dir = args[1], type = args[2], filter.exp = args[3])
