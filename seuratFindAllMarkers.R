#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(Seurat))
# utilsFanc::attach.fanc("igraph")
options(stringsAsFactors = F)
args <- commandArgs(trailingOnly = T)
so <- readRDS(args[1])
work.dir <- args[2]
assay <- args[3]

markers <- FindAllMarkers(object = so)
try(write.table(markers, paste0(args[2], "/markers.tsv"), quote = F, sep = "\t",
                col.names = T, row.names = F))
saveRDS(markers, paste0(work.dir, "/markers.Rds"))