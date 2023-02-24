suppressMessages(library(dplyr))
suppressMessages(library(rtracklayer))
options(stringsAsFactors = F)
gtf <- commandArgs(trailingOnly = T)

out.bed <- paste0(tools::file_path_sans_ext(gtf), ".bed")
gtf <- rtracklayer::import(gtf)
gtf <- gtf[gtf$type == "exon"]

gtf$name <- paste0("exon", gtf$exon_number, "_",gtf$transcript_id)
mcols(gtf) <- mcols(gtf)[, "name", drop = F]

utilsFanc::write.zip.fanc(gtf, out.bed, bed.shift = T)