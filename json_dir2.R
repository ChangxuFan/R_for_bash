#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("-d", "--dir", required = F, default="./")
parser$add_argument("-t", "--type",required = F, default="ext")
parser$add_argument("-g", "--genome",required = F, default=NULL)
parser$add_argument("-f", "--filter",required = F, default = NULL)
parser$add_argument("-j", "--json", required = F, default = NULL)
parser$add_argument("-r", "--recursive",required = F, action = "store_true", default = F)
parser$add_argument("--strip", required = F, action = "store_true", default = F)
parser$add_argument("--glob", required = F, default =  NULL, nargs='+')
parser$add_argument("--prefix", required = F, default =  NULL)
parser$add_argument("--group", required = F, default =  NULL)

args <- parser$parse_args()

# args <- parser$parse_args(c("-t", "bigwig", "-f", "WangT.*"))

json.gen.dir <- function(dir, files = NULL, glob, type, filter.exp = NULL, genome = NULL,
  recursive = F, strip.dir = F, prefix = NULL, debug = F, json.name = NULL, group = NULL) {
  #files <- Sys.glob(paste0(dir, "/*")) %>% basename()
  if (is.null(files))
    files <- list.files(dir, recursive = recursive)

  files <- files[!grepl(".json", files)] %>% .[!grepl(".tbi$", .)]
  if (!is.null(filter.exp))
    files <- files[grepl(filter.exp, files)]

  if (type == "igv") {
    print(files)
    abaFanc::igv.hubgen(files, no.writing = F)
    return()
  }

  jsongen <- lapply(files, function(x) {
    if (type == "ext") {
      type <- get.type(x)
    }

    url <- x
    if (strip.dir == T) {
      x <- basename(x) 
    }
    if (!is.null(prefix))
      x <- paste0(prefix, "..", x)
    json.sub <- list(name = x,
                url = url,
                type = type)
    if (type == "genomealign") {
      print("paring query genome from file name")
      query.genome <- x %>% stringr::str_extract("[0-9A-Za-z]+.align") %>% 
      sub(".align", "", .)
      json.sub$querygenome <- query.genome
    }
    if (!is.null(genome)) {
      json.sub$metadata <- list(genome = genome)
    }
    if (!is.null(group)) {
      json.sub$options <- list(group = as.numeric(group))
    }
    return(json.sub)
  })
  json <- jsongen %>% jsonlite::toJSON(auto_unbox = T)  %>% jsonlite::prettify()
  if (is.null(json.name))
    json.name <- "files.json"
  json.file <- paste0(dir, "/", json.name)
  write(json, json.file)
  cat(utilsFanc::bash2ftp(json.file)); cat("\n")
  if (debug == T)
    return(json)
  else
    return()
}

get.type <- function(x) {
  lookup <- c(bw = "bigwig", bigwig = "bigwig", bigWig = "bigwig", 
    bdg = "bedgraph", bedgraph = "bedgraph", bedGraph = "bedgraph", bg = "bedgraph",
    methylC = "methylC",
    bed = "bed", narrowPeak = "bed",  bam = "bam", lr = "longrange", cat = "categorical",
    hic = "hic", cool = "cool", qbed= "qbed",
    align = "genomealign", genomeAlign = "genomealign")
  ext <- sub(".gz$","",basename(x)) %>% tools::file_ext()
  type <- lookup[ext]
  if (sum(is.na(type)) != 0) {
    warning(paste0("the type of these files cannot be parsed: \n", paste0(x[is.na(type)], collapse = "\n")))
  }
  return(type)
}

json.gen.dir(dir = args$dir, files = args$glob, prefix = args$prefix,
  type = args$type, filter.exp = args$filter, json.name = args$json,
  genome = args$genome,
  recursive = args$recursive, strip.dir = args$strip, group = args$group)