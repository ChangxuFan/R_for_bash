#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
# suppressMessages(library("argparse"))
options(stringsAsFactors = F)
args <- commandArgs(trailingOnly = T)
file <- args[1]
query.genome <- args[2]
type <- args[3]
if (is.na(type)) {
	type <- "genomeAlign"
}
out.json <- paste0(file, ".json")
utilsFanc::align.json(files = file, query.genome = query.genome, 
	type = type, out.json = out.json)