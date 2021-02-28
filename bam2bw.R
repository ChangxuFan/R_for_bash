#!/opt/apps/R/3.6.1/bin/Rscript
args <- commandArgs(trailingOnly=TRUE)
rnaSeqFanc::bam.browser(bam = args[1], thread = as.numeric(args[2]))