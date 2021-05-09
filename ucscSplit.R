#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))
suppressMessages(library(parallel))
options(stringsAsFactors = F)
options(scipen = 999)
parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-i", "--in.file", required = T)
parser$add_argument("-o", "--out.dir", required = T)
parser$add_argument("-z", "--zip",required = F, action = "store_true", default = T)
parser$add_argument("-t", "--threads",required = F, default = 1)


args <- parser$parse_args()
ucsc.header.get.field <- function(header.vec, field.name) {
  value <- stringr::str_extract(pattern = paste0(field.name, "=[^ ]+"), string = header.vec) %>% 
    sub(paste0(field.name, "="), "",.)
  return(value)
}

split.ucsc <- function(in.file, out.dir, zip = T, threads = 1) {
  system(paste0("mkdir -p ", out.dir))
  headers <- tempfile()
  cmd <- paste0("grep -n \"track name\" ", in.file, " > ",headers)
  system(cmd)
  header.vec <- readLines(headers)
  track.lines <- header.vec %>% sub(":.+$", "", .) %>% as.numeric()
  wc.l <- system(paste0("wc -l ", in.file), intern = T) %>% sub(" .+$", "", .) %>% as.numeric()
  
  
  range.df <- data.frame(start = track.lines + 1, 
                         end = c(track.lines[-1] - 1, wc.l),
                         name = header.vec %>% ucsc.header.get.field("track name") %>% sub(" +", "_",.),
                         type = header.vec %>% ucsc.header.get.field("type"))
  out.files <- range.df %>% split(f = 1:nrow(range.df)) %>% 
    mclapply(function(r) {
      out.file <- paste0(out.dir, "/",r$name, ".", r$type)
      cmd <- paste0("sed -n '", r$start, ",", r$end,"p;", r$end+1,"q' ", in.file, " > ",
                    out.file)
      # print(cmd)
      system(cmd)
      if (zip == T) {
        system(paste0("/bar/cfan/scripts/bed_browser_v2.sh ", out.file))
        out.file <- paste0(out.file, ".gz")
      }
      return(out.file)
    }, mc.cleanup = T, mc.cores = threads) %>% unlist()
  return(out.files)
}

split.ucsc(in.file = args$in.file, out.dir = args$out.dir, zip = args$zip, threads = args$threads) %>% cat()