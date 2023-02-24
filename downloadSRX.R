#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(downloadSRX))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)
parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("--sraTools", action = "store_true")
parser$add_argument("--wget", action = "store_true")
parser$add_argument("--dl.tsv", required = F, default="dl.tsv")
parser$add_argument("--dl.sh", required = F, default = "dl.sh")
parser$add_argument("--sample.info.tsv", required = F, default = "sample_info.tsv")
parser$add_argument("-a", "--not.require.fastq", action = "store_true")
parser$add_argument("--fastq.dir", required = F, default = "fastq_ori/")
parser$add_argument("--annot", required = F, default = NULL)
parser$add_argument("--genome.index", required = F, default = NULL)
parser$add_argument("--sraThreads", required = F, default = 2)
parser$add_argument("--nreads", required = F, default = NULL)
parser$add_argument("--aws", action = "store_true")
args <- parser$parse_args()

t <- download.filegen(download.info = args$dl.tsv, download.dir = args$fastq.dir,
                 out.file = args$dl.sh, out.sample.info = args$sample.info.tsv,
                 annot = args$annot, genome.index = args$genome.index, 
		use.ascp = !args$wget, ena.require.fastq = !args$not.require.fastq,
                 use.sratools=args$sraTools, sratools.thread=args$sraThreads, force.n.reads = args$nreads,
                 ena.swap.aws = args$aws)
