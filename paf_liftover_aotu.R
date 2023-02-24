#!/opt/apps/R/3.6.1/bin/Rscript
source("~/R_packages/common/base.R")
suppressMessages(library("argparse"))

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-p", "--paf", required = T)
parser$add_argument("-b", "--bed",required = T)
parser$add_argument("-o", "--outdir",required = T)
parser$add_argument("-d", "--dist", required = T)
parser$add_argument("-s", "--size", required = T)

parser$add_argument("-m", "--min.l", required = F, default = 10000)
args <- parser$parse_args()

abaFanc::paf.liftover.aotu(bed = args$bed, paf = args$paf, min.l = args$min.l,
	dist = args$dist, size = args$size, 
	out.dir = args$outdir)