#!/opt/apps/R/3.6.1/bin/Rscript
library(rnaSeqFanc)

args = commandArgs(trailingOnly=TRUE)

samples <- read.table(args[1], as.is=T, header = T ) 
genome = args[2]
thread = args[3]
mc.cores.GSM = args[4]
mc.cores.SRR = args[5]

if (is.na(mc.cores.GSM)) {
  mc.cores.GSM <- 2
}

if (is.na(mc.cores.SRR)) {
  mc.cores.SRR <- 1
}

options(stringsAsFactors = F)
rna.seq(fastq.info = samples, genome.index = Sys.glob(paste0("/bar/cfan/genomes/", genome,"/STAR_gencode_vM*"))[1],
        annot = Sys.glob(paste0("/bar/cfan/genomes/",genome, "/gencode/gencode.*.annotation.gtf"))[1], qc = T, pe.rmdup = T, se.rmdup = F, 
        filter.expression.se = "mapping_quality >= 30 and (not secondary_alignment)", count.out.name = "./rna.count",
        filter.expression.pe = "mapping_quality >= 30 and (not secondary_alignment)",
	      count.frac.overlap = 0.5, other.count.options.se = "", other.count.options.pe = "",
        fastqc.dir = "./fastqc/", fastp.out.dir = "./fastp/", 
        generate.bw = T, bw.dir = "./bw/", thread = thread, align.out.dir = "./star_aligned/", 
        normalization = "RPKM", mc.cores.GSM = mc.cores.GSM, mc.cores.SRR = mc.cores.SRR, other.bw.options = "")
