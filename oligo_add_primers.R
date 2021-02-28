library(dplyr)
args = commandArgs(trailingOnly=TRUE)
oligos.fa <- args[1]
primers.fa <- args[2]
primer.l <- args[3]
primer.r <- args[4]
outfile <- args[5]


olg <- seqinr::read.fasta(oligos.fa)
prm <- seqinr::read.fasta(primers.fa)

seqs.cat <- lapply(olg, function(x) {
	seq.cat <- c(prm[[primer.l]], x, prm[[primer.r]]) %>% paste0(collapse = "")
	return(seq.cat)
	})
seqs.name <- sapply(olg, function(x) {
	seq.name <- attr(x, "name")
	return(seq.name)
	})

seqinr::write.fasta(seqs.cat,seqs.name , outfile)
