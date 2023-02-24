#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-d", "--masterDir", required = F, default="./")
parser$add_argument("-s", "--samples", required = F, default =  NULL, nargs='+')
parser$add_argument("-r", "--readLength", required = T)
parser$add_argument("-g", "--genome", required = T)
parser$add_argument("--template", required = F, default =  "~/software/CUT-RUNTools-2.0/config/template.json")
parser$add_argument("-t", "--threads", required = T)

args <- parser$parse_args()

if (is.null(args$samples)) {
  args$samples <- list.dirs(path = paste0(args$masterDir, "/fastq/"), full.names = F, recursive = F)
}

samples.not.found <- args$samples %>% .[!dir.exists(paste0(args$masterDir, "/fastq/",.))]
if (length(samples.not.found) > 0) {
  stop(paste0("some samples are not found: \n", paste0(samples.not.found, collapse = "\n")))
}

json <- jsonlite::read_json(args$template)
lapply(args$samples, function(sample) {
  json$input_output$fastq_directory <- paste0(args$masterDir, "/fastq/", sample) %>% normalizePath()
  json$input_output$workdir <- paste0(args$masterDir, "/process/") %>% normalizePath()
  json$input_output$fastq_sequence_length <- args$readLength
  json$input_output$organism_build <- args$genome
  json$input_output$cores <- args$threads
  trash <- jsonlite::toJSON(json, auto_unbox = T) %>% jsonlite::prettify() %>% 
    write(paste0(args$masterDir, "/config/", sample, ".json"))
  return()
})
