#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library(parallel))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-i", "--in.bdg.glob", required = T)
parser$add_argument("-g", "--genome",required = T)
parser$add_argument("-s", "--suffix",required = F, default="bdg")
parser$add_argument("-t", "--threads",required = F, default = 6)

args <- parser$parse_args()

add.params <- "-blockSize=32 -itemsPerSlot=32"
bdg2bw <- function(bdg.glob, genome, suffix = "bdg", threads = 6,
                   bedGraphToBigWig = "/bar/cfan/.local/bin/bedGraphToBigWig",
                   add.params = add.params) {
  bdgs <- Sys.glob(bdg.glob)
  trash <- mclapply(bdgs, function(bdg) {
    bw <- sub(suffix, "bw", bdg)
    tempt <- tempfile()
    cmd <- paste0("sort -k1,1 -k2,2n ", bdg, " > ", tempt)
    system(cmd)
    genome.size <- paste0("/bar/cfan/genomes/", genome, "/", genome, ".chrom.sizes")
    cmd <- paste0(bedGraphToBigWig, " ", tempt, " ", genome.size, " ", bw, " ", add.params)
    system(cmd)
    return(NULL)
  })
  return(NULL)
}

bdg2bw(bdg.glob = args$in.bdg.glob, genome = args$genome, 
	suffix = args$suffix, threads = args$threads)