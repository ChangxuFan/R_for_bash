#!/opt/apps/R/3.6.1/bin/Rscript
source("~/R_packages/common/base.R")
in.fa <- commandArgs(trailingOnly = T)[1]
out.fa <- in.fa %>% tools::file_path_sans_ext() %>% paste0(".nexus")
data <- seqinr::read.fasta(in.fa, forceDNAtolower = F)
ape::write.nexus.data(data, file = out.fa)