#!/opt/apps/R/3.6.1/bin/Rscript
args <- commandArgs(trailingOnly=TRUE)
file <- args
cat(utilsFanc::bash2ftp(file), 	sep = "\n")

