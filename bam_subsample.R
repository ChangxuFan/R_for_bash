#!/opt/apps/R/3.6.1/bin/Rscript
source("~/R_packages/common/base.R")
suppressMessages(library("argparse"))

samtools <- "/bar/cfan/anaconda2/envs/jupyter/bin/samtools"

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-b", "--bam", required = F, nargs = "+", default = NULL)
parser$add_argument("-N", "--nreads.tsv", required = F, default = "nread.tsv")
parser$add_argument("-R", "--reuse", required = F, default = F, action = "store_true")

parser$add_argument("-o", "--outdir", required = T)
parser$add_argument("-n", "--sub.to", required = T, type = "integer")
parser$add_argument("-s", "--seed", required = F, type = "integer", default = 0)

parser$add_argument("-t", "--threads.each", required = F, type = "integer", default = 1)
parser$add_argument("-T", "--threads.master", required = F, type = "integer", default = NULL)
parser$add_argument("--nono", required = F, default = F, action = "store_true")
parser$add_argument("--no_index", required = F, default = F, action = "store_true")

args <- parser$parse_args()
# args <- parser$parse_args(c("-t", "1", "-b", "test", "-o", "test", "-n", 4000000))
utilsFanc::t.stat("counting reads`")
if (!is.null(args$bam)) {
  file.not.found <- args$bam %>% .[!file.exists(.)]
  if (length(file.not.found) > 0)
    stop(paste0("These bams not found:\n", paste0(file.not.found, collapse = "\n")))
  
  if (is.null(args$threads.master)) {
    args$threads.master <- length(args$bam)
  }
  
  if (args$reuse == T) {
    if (file.exists(args$nreads.tsv)) {
      nreads.df <- read.table(args$nreads.tsv, header = T)
      bam.to.count <- args$bam %>% .[!normalizePath(.) %in% normalizePath(nreads.df$bam)]
    } else {
      bam.to.count <- args$bam
    }
  } else {
    bam.to.count <- args$bam
  }
  
  cat(paste0("counting these bam files:\n", paste0(bam.to.count, collapse = "\n")))
  cat("\n")
  
  if (length(bam.to.count) > 0) {
    df <- utilsFanc::safelapply(bam.to.count, function(bam) {
      cmd <- paste0(samtools, " view -c ", bam)
      print(cmd)
      nreads <- system(cmd, intern = T)
      df <- data.frame(bam = bam, nreads = nreads)
      return(df)
    }, threads = args$threads.master) %>% Reduce(rbind, .)
    if (file.exists(args$nreads.tsv) && args$reuse == T) {
      df <- rbind(nreads.df, df)
    }
    dir.create(dirname(args$nreads.tsv), showWarnings = F, recursive = T)
    write.table(df, args$nreads.tsv, col.names = T, row.names = F, sep = "\t", quote = F)
  }
  
}
utilsFanc::t.stat("subsetting phase")
nreads.df <- read.table(args$nreads.tsv, header = T)

if (!is.null(args$bam)) {
  nreads.df <- nreads.df %>% .[normalizePath(.$bam) %in% normalizePath(args$bam),]
}

dir.create(args$outdir, showWarnings = F, recursive = T)


nreads.df <- nreads.df %>% 
  mutate(outfile = paste0(args$outdir, "/", utilsFanc::insert.name.before.ext(basename(bam),
                                                                              paste0("subto_", utilsFanc::so.formatter(args$sub.to)), 
                                                                              delim = "_"))) %>% 
  mutate(s = round(args$seed + args$sub.to/nreads, digits = 4))

print(nreads.df)

nreads.df %>% split(., f = 1:nrow(.)) %>% 
  utilsFanc::safelapply(function(x) {
    if (x$nreads > args$sub.to) {
      cmd <- paste0(samtools, " view -hbo ", x$outfile, " -@ ", args$threads.each, " -s ", x$s, " ", x$bam)
    } else {
      cmd <- paste0("rsync -a ", x$bam, " ", x$outfile)
    }
    if (args$no_index == F) {
      cmd <- paste0(cmd, " && ", samtools, " index ", x$outfile)
    }
    print(cmd)
    if (args$nono == F)
      system(cmd)
    return(NULL)
  }, threads = args$threads.master)