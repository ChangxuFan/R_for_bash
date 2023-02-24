#!/bar/cfan/anaconda2/envs/ren/bin/Rscript
.libPaths(c("/bar/cfan/R/x86_64-pc-linux-gnu-library/3.6", 
            "/opt/apps/R/3.6.1/lib/R/library"))
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)
parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-f", "--file", required = T)
parser$add_argument("-s", "--skip.firstn", required = F, default = 0, type = "integer" )

args <- parser$parse_args()

match.md5 <- function(file, skip.firstn) {
  file <- read.table(file = file, skip = skip.firstn)
  file %>% split(., f = 1:nrow(.)) %>% 
    lapply(function(x) {
      md5.truth <- suppressWarnings(readLines(paste0(x$V2, ".md5"))) %>% sub("( |\t).+$", "", . )
      if (!identical(md5.truth, x$V1)) {
        stop(paste0("md5 doesn't match\n",
                    "original: ", md5.truth, "\n",
                    "found: ", x$V1, "\n"))
      } else {
        print(paste0("match: ", x$V2, " ", x$V1, " ", md5.truth))
      }
      return()
    })
  invisible()
}

match.md5(file = args$file, skip.firstn = args$skip.firstn)