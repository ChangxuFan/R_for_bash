#!/opt/apps/R/3.6.1/bin/Rscript
options(stringsAsFactors = F)
library(dplyr)
args <- commandArgs(trailingOnly = T)

in.file <- args[1]
df <- read.table(in.file, as.is = T, sep = "\t", quote = "", header = F)
# conventional chromosomes (main assembly)
out.conv <- paste0(in.file, ".conv")
df.conv <- df[grepl("^chr\\d+$",df$V1) | grepl("^chr[XY]$",df$V1),]
write.table(df.conv, out.conv, col.names = F, row.names = F, quote = F, sep = "\t")

out.convM <- paste0(in.file, ".convM")
df.convM <- df[grepl("^chr\\d+$",df$V1) | grepl("^chr[XYM]$",df$V1),]
write.table(df.convM, out.convM, col.names = F, row.names = F, quote = F, sep = "\t")

out.convYless <- paste0(in.file, ".convYless")
df.convYless <- df[grepl("^chr\\d+$",df$V1) | grepl("^chr[X]$",df$V1),]
write.table(df.convYless, out.convYless, col.names = F, row.names = F, quote = F, sep = "\t")