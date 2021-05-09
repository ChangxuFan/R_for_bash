#!/opt/apps/R/3.6.1/bin/Rscript
library(dplyr)
library(parallel)
## modify the name of fastq sequencing files to make them adherent to rnaSeqFanc name convention
in.fastqs <- commandArgs(trailingOnly = T)
# avoid dealing with index files:
in.fastqs <- in.fastqs %>% .[!grepl("I[12].fastq", .)] %>% 
  .[!grepl("I[12]_\\d+.fastq", .)]

## establish softlinks:
# cmd <- paste0("ln -s ", paste0(in.fastqs, collapse = " "), " ./")
mclapply(in.fastqs, function(x) {
	cmd <- paste0("rsync ", x, " ./")
	print(cmd); system(cmd)
	}, mc.cores = length(in.fastqs), mc.cleanup = T)



paste0("rename -v 's/SIC(\\d+)_[A-Za-z]+_S\\d+_/GSM\\1\\1_SRR\\1\\1_/g' * ") %>% system()

paste0("rename 's/R1_001.fastq.gz/1.fastq.gz/g' *") %>% system()

paste0("rename 's/R2_001.fastq.gz/2.fastq.gz/g' *") %>% system()

