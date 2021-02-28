#!/opt/apps/R/3.5.1/bin/Rscript
suppressMessages(library(downloadSRX))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)
parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("--sraTools", action = "store_true")
parser$add_argument("--dl.tsv", required = F, default="dl.tsv")
parser$add_argument("--dl.sh", required = F, default = "dl.sh")
parser$add_argument("--sample.info.tsv", required = F, default = "sample_info.tsv")
parser$add_argument("--fastq.dir", required = F, default = "fastq/")
parser$add_argument("--annot", required = F, default = NULL)
parser$add_argument("--genome.index", required = F, default = NULL)
parser$add_argument("--sraThreads", required = F, default = 10)
parser$add_argument("--nreads", required = F, default = NULL)
args <- parser$parse_args()

t <- download.filegen(download.info = args$dl.tsv, download.dir = args$fastq.dir,
                 out.file = args$dl.sh, out.sample.info = args$sample.info.tsv,
                 annot = args$annot, genome.index = args$genome.index, 
                 use.sratools=args$sraTools, sratools.thread=args$sraThreads, force.n.reads = args$nreads, 
                 use.ascp = T)
