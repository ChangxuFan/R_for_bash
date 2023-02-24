#!/opt/apps/R/3.6.1/bin/Rscript
in.fa <- commandArgs(trailingOnly = T)
abaFanc2::fasta2phylip(in.fa)