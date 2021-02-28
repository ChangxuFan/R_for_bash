#!/opt/apps/R/3.5.1/bin/Rscript
Sys.getenv("R_HOME")
.libPaths()
# args <- commandArgs(trailingOnly=TRUE)
# in.ao.Rds <- args[1]
# out.ao.Rds <- args[2]
# genome <- args[3]
# library(ArchR)
# addArchRThreads(threads = 12) 
# addArchRGenome(genome)

# ao <- readRDS(in.ao.Rds)
# ao <- addUMAP(
#   ArchRProj = ao, 
#   reducedDims = "IterativeLSI", 
#   name = "UMAP", 
#   nNeighbors = 30, 
#   minDist = 0.5, 
#   metric = "cosine",
#   force = force
# )

# saveRDS(ao, out.ao.Rds)