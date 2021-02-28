library(Seurat)
utilsFanc::attach.fanc("igraph")
options(stringsAsFactors = F)
args <- commandArgs(trailingOnly = T)
so <- readRDS(args[1])
assay <- args[3]
markers <- FindAllMarkers(object = so)
try(write.table(markers, paste0(args[2], "/markers.tsv"), quote = F, sep = "\t",
                col.names = T, row.names = F))
saveRDS(markers, paste0(args[2], "/markers.Rds"))