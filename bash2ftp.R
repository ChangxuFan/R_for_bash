#!/opt/apps/R/3.6.1/bin/Rscript
args <- commandArgs(trailingOnly=TRUE)
file <- args[1]
cat(utilsFanc::bash2ftp(file))
cat("\n")
