source("~/hmtp/scAR/test_run/objects.R")
library(ArchR)

args <- commandArgs(trailingOnly = T)

so <- readRDS(args[1])
ao <- readRDS(args[2])
genome <- args[3]
meta <- args[4]
master.dir <- args[5]
thread.master <- args[6]
thread.sub <- args[7]

addArchRThreads(threads = 12) 
addArchRGenome(genome)

t <- per.cluster.macs2(so = so,ao = ao, genome = genome, 
                           meta = meta, sort = T, thread.master = thread.master,
                           thread.sub = thread.sub,
                           master.dir = master.dir)