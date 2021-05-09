#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
options(stringsAsFactors = F)
options(scipen = 99)

args <- commandArgs(trailingOnly = T)
rmsk <- args[1]
col.num <- args[2]
if (is.na(col.num)) {
	col.num <- 12
}

rmsk.simple <- abaFanc::rmsk.simple.gen(rmsk.in = rmsk, col.num = col.num, zip = T)
cat(rmsk.simple)
cat("\n")