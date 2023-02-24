options(stringsAsFactors = F)
options(scipen = 20)
suppressMessages(library(dplyr))
suppressMessages(library(rlang))
suppressMessages(library(rtracklayer))
suppressMessages(library(GenomicRanges))
suppressMessages(library(argparse))

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-b", "--bw", required = T)
parser$add_argument("-o", "--out.bed", required = F, default=NULL)
parser$add_argument("-z", "--bgzip", required = F, default= "/bar/cfan/anaconda2/envs/jupyter/bin/bgzip")
parser$add_argument("-t", "--tabix", required = F, default= "/bar/cfan/anaconda2/envs/jupyter/bin/tabix")

args <- parser$parse_args()

bw.zero <- function(in.bw, out.bed, bgzip = BGZIP, tabix = TABIX) {
  in.gr <- rtracklayer::import(in.bw)
  # chrom.sizes <- seqinfo(in.gr) %>% as.data.frame() %>% .[, 1, drop = F] %>% 
  #   mutate(., chr = rownames(.), start = 1, end = seqlengths) %>% 
  #   makeGRangesFromDataFrame()
  zero.gr <- in.gr[in.gr$score == 0]
  zero.gr$score <- width(zero.gr)
  colnames(mcols(zero.gr)) <- "size"
  dir.create(dirname(out.bed), showWarnings = F, recursive = T)
  rtracklayer::export.bed(zero.gr, out.bed)
  system(paste0(bgzip, " -c -f ", out.bed, " > ", out.bed, ".gz"))
  system(paste0(tabix, " -f -p bed ", out.bed, ".gz"))
  return(out.bed)
}

bw.zero(in.bw = args$bw, out.bed = args$out.bed, bgzip = args$bgzip, tabix = args$tabix)