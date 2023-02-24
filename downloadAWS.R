#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(downloadSRX))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-i", "--dl.tsv", required = F, default= "dl.tsv")
parser$add_argument("-x", "--dl.sh", required = F, default = NULL)
parser$add_argument("-d", "--dl.dir",  required = F, default = "fastq_ori")
parser$add_argument("-t", "--sraThreads", required = F, default = 2)
parser$add_argument("-o", "--get.ori", action = "store_true")
args <- parser$parse_args()
if (is.null(args$dl.sh)) {
  args$dl.sh <- paste0(tools::file_path_sans_ext(args$dl.tsv), ".sh")
}

trash <- download.aws(download.info = args$dl.tsv, dl.sh = args$dl.sh, 
                      dl.dir = args$dl.dir, get.ori = args$get.ori, sra.dump.threads = args$sraThreads)
