#!/opt/apps/R/3.6.1/bin/Rscript
options(stringsAsFactors = F)
options(scipen = 20)
suppressMessages(library(dplyr))
suppressMessages(library(rlang))
suppressMessages(library(Rsamtools))
suppressMessages(library(argparse))

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-b", "--bam", required = T)
parser$add_argument("-o", "--out.bam", required = F, default=NULL)
parser$add_argument("-r", "--valid.reads", required = T)

args <- parser$parse_args()

bam.filter.mqa <- function(bam, out.bam = NULL, valid.reads) {
  reads <- readLines(valid.reads) %>% unique()
  filter <- function(x) x$qname %in% reads
  filters <- list(name.filter = filter)
  if (is.null(out.bam))
    out.bam <- sub(".bam", "_mqa.bam", bam)
  Rsamtools::filterBam(file = bam, destination = out.bam, filter = FilterRules(filters))
  return(out.bam)
}

bam.filter.mqa(bam = args$bam, out.bam = args$out.bam, valid.reads = args$valid.reads)
