#!/opt/apps/R/3.6.1/bin/Rscript
source("~/R_packages/common/base.R")
parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-i", "--tsv", required = F, default="./dl_encode.tsv")
parser$add_argument("-s", "--sh", required = F, default="./dl_encode.sh")
parser$add_argument("-D", "--dir", required = F, default="./fastq_encode/")

args <- parser$parse_args()

# sample	link
# encode_K562_Lecuyer_rep1	https://www.encodeproject.org/files/ENCFF059IUV/@@download/ENCFF059IUV.fastq.gz


df <- read.table(args$tsv, header = T)

dir.create(args$dir, showWarnings = F, recursive = T)

cmds <- df %>% split(., f = factor(.$sample, levels = unique(.$sample))) %>% 
  lapply(function(df) {
    if (nrow(df) == 2) {
      if (! "mate" %in% colnames(df)) {
        df$mate <- c(1, 2)
      }
      cmds <- paste0("wget -c --limit-rate=10m ", df$link, " -O ",
                    args$dir, "/", df$sample, 
                    "_R", df$mate, ".fastq.gz")
    } else if (nrow(df) == 1) {
      cmds <- paste0("wget -c --limit-rate=10m ", df$link, " -O ",
                     args$dir, "/", df$sample,
                     ".fastq.gz")
    } else {
      stop("nrow(df) has to be 1 or 2")
    }
    return(cmds)
  }) %>% unlist()

cmds <- c("#!/bin/bash", cmds)
dir.create(dirname(args$sh), showWarnings = F, recursive = T)

write(cmds, file = args$sh, sep = "\n")