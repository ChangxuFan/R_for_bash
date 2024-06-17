#!/opt/apps/R/3.6.1/bin/Rscript

# fields required in tsv: srx, sample. instead of srx, gsm is also okay
# -t: bed or bw
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-i", "--dl.tsv", required = F, default= "chipatlas_dl.tsv")
parser$add_argument("-t", "--type", required = F, default= "bed")
parser$add_argument("-q", "--qcutoff", required = F, default= "05")
parser$add_argument("-g", "--genome", required = T)

args <- parser$parse_args()

df <- suppressWarnings(read.table(args$dl.tsv, header = T))

if ("gsm" %in% colnames(df)) {
	df$srx <- downloadSRX::gsm2srx(df$gsm)
}

utilsFanc::check.intersect(c("srx", "sample"), "required columns", colnames(df), "colnames(dl.tsv)")

out.files <- paste0(df$sample, "_", df$srx, ifelse(args$type == "bed", paste0(".", args$qcutoff), ""), ".", 
	ifelse(args$type == "bed", "narrowPeak", args$type))

cmd <- paste0("wget -c https://chip-atlas.dbcls.jp/data/", 
	args$genome, "/eachData/", args$type, ifelse(args$type == "bed", args$qcutoff, ""), "/",
	df$srx, ifelse(args$type == "bed", paste0(".", args$qcutoff), ""), ".", args$type, 
	" -O ", out.files)
if (args$type == "bed") {
	cmd <- paste0(cmd, " && bb.sh ", out.files)
}

cmd <- c("#!/bin/bash", cmd)
write(cmd, "chipatlas_dl.sh", sep = "\n")
system("chmod 755 chipatlas_dl.sh")