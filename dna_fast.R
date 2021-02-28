library(rnaSeqFanc)
args = commandArgs(trailingOnly=TRUE)

samples <- read.table(args[1], as.is=T, header = T ) %>% pull(fastqfile)
genome = args[2]
thread = args[3]
qc = args[4]
if (!is.na(qc)) {
	qc <- T
}

options(stringsAsFactors = F)
dna.seq(samples, 
genome.index = paste0("/bar/cfan/genomes/",genome, "/bowtie2/",genome), thread = thread, qc = qc, pe.rmdup = T, se.rmdup = F, 
filter.expression = "mapping_quality >= 30 and (not secondary_alignment)",  fastp.out.dir= "./fastq/", 
other.dedup.options = " --hash-table-size=5000000 --overflow-list-size=5000000 ",
align.out.dir="./bowtie2_aligned/")

