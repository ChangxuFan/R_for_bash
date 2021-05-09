#!/opt/apps/R/3.6.1/bin/Rscript
library(dplyr)
library(parallel)
library(liteRnaSeqFanc)
options(stringsAsFactors = F)


args <- commandArgs(trailingOnly = T)
threads.master <- args[1]
threads.sub <- args[2]
fastqs <- args[3:length(args)]

cutadapt.target(fastqs, "./cutadapt/", threads.master = threads.master, threads.sub = threads.sub)