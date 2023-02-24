#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library(rtracklayer))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-g", "--gtf", required = T, help = "input gtf file")
parser$add_argument("-b", "--bed", required = T, help = "output tss file in bed format")
parser$add_argument("-a", "--all", required = F, action = "store_true", 
    help = "use all transcript, including those that are not protein_coding")


args <- parser$parse_args()

gtf <- rtracklayer::import(args$gtf)
gtf <- gtf[gtf$type == "transcript"]
if (!args$all) {
    gtf <- gtf[gtf$gene_type == "protein_coding"]
} else {
    print("not filtering for protein_coding. Using all transcripts")
}

gtf <- gtf %>% as.data.frame() %>% 
 dplyr::rename(chr = seqnames) %>% 
 dplyr::select(chr, start, end, gene_name, transcript_id, strand)

gtf$Start <- gtf$start # Start: stranded start
gtf$Start[gtf$strand == "-"] <- gtf$end[gtf$strand == "-"]
gtf$start <- gtf$Start - 1
gtf$end <- gtf$Start
gtf$Start <- NULL
gtf <- gtf %>% arrange(chr, start)
utilsFanc::write.zip.fanc(gtf, out.file = args$bed, ez = T)
