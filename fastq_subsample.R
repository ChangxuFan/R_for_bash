#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library(parallel))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)
options(scipen = 999)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-i", "--in.fastq", required = T, nargs = "+")
parser$add_argument("-o", "--out.dir", required = T)
parser$add_argument("-n", "--n.million", required = T, type = "integer")
parser$add_argument("-s", "--seed", required = F, default = 123, type = "integer")
parser$add_argument("-t", "--threads", required = F, default = 6, type = "integer")
args <- parser$parse_args()

if (args$n.million > 500) {
  stop("note -n is n million reads!")
}

if (args$threads > 11) {
  stop("note threads is for each pair. By default the 2 mates of each pair is parallel.")
}

not.found <- args$in.fastq %>% .[!file.exists(.)]
if (length(not.found) > 0) {
  stop(paste0("files not found: \n",
              paste0(not.found, collapse = "\n")))
}

liteRnaSeqFanc::fastq.subsample(in.fastqs = args$in.fastq, out.dir = args$out.dir,
                                n.reads = 1000000 * args$n.million, run = T,
                                threads = args$threads, seed = args$seed, save.mem = T,
                                seqtk = "seqtk")
