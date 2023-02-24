#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library(parallel))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-i", "--in.bdg.glob", required = T, nargs = "+")
parser$add_argument("-g", "--genome",required = T)
parser$add_argument("-s", "--suffix",required = F, default="bdg")
parser$add_argument("-t", "--threads",required = F, default = 6)

args <- parser$parse_args()

add.params <- "-blockSize=32 -itemsPerSlot=32"
bdg2bw <- function(bdgs, genome, suffix = "bdg", threads = 6,
                   bedGraphToBigWig = "/bar/cfan/.local/bin/bedGraphToBigWig",
                   add.params = "") {
  trash <- utilsFanc::safelapply(bdgs, function(bdg) {
    bw <- sub(suffix, "bw", bdg)
    tempt <- tempfile()
    cmd <- paste0("sort -k1,1 -k2,2n ", bdg, " > ", tempt)
    print(cmd); system(cmd)
    genome.size <- paste0("/bar/cfan/genomes/", genome, "/", genome, ".chrom.sizes")
    cmd <- paste0(bedGraphToBigWig, " ", tempt, " ", genome.size, " ", bw, " ", add.params)
    print(cmd); system(cmd)
    return(NULL)
  }, threads = threads)
  return(NULL)
}

bdg2bw(bdgs = args$in.bdg.glob, genome = args$genome, 
	suffix = args$suffix, threads = args$threads)