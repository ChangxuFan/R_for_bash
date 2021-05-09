#!/opt/apps/R/3.6.1/bin/Rscript
options(stringsAsFactors = F)
options(scipen = 99)
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-p", "--paf", required = T)
parser$add_argument("-b", "--bed",required = T)
parser$add_argument("-l", "--lifted",required = F, default = NULL)
parser$add_argument("-u", "--unlifted", required = F, default = NULL)
args <- parser$parse_args()

liteRnaSeqFanc::paf.liftover(bed = args$bed, paf = args$paf, lifted.bed = args$lifted, 
	unlifted.bed = args$unlifted)