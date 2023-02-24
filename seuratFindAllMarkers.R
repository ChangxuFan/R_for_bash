#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(Seurat))
# utilsFanc::attach.fanc("igraph")
options(stringsAsFactors = F)
suppressMessages(library("argparse"))

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-s", "--so", required = F, default="./soi.Rds")
parser$add_argument("-d", "--work.dir",required = F, default="./")
parser$add_argument("-a", "--assay",required = F, default="RNA")
parser$add_argument("-t", "--threads",required = F, default=4, type = "integer")

args <- parser$parse_args()

if (args$threads > 1) {
    print("using multi cores")
    library(future)
    plan("multiprocess", workers = args$threads)
}

options(future.globals.maxSize = 12000 * 1024^2)

so <- readRDS(args$so)
markers <- FindAllMarkers(object = so, assay = args$assay)
try(write.table(markers, paste0(args$work.dir, "/markers.tsv"), quote = F, sep = "\t",
                col.names = T, row.names = F))
saveRDS(markers, paste0(args$work.dir, "/markers.Rds"))
