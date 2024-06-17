#!/opt/apps/R/3.6.1/bin/Rscript
suppressMessages(library(dplyr))
suppressMessages(library("argparse"))
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)

parser$add_argument("files", default =  NULL, nargs='+')

parser$add_argument("-o", "--out.name", required = F, default="timestamp")

parser$add_argument("-t", "--type",required = F, default="ext")
parser$add_argument("-g", "--genome",required = F, default=NULL)
parser$add_argument("-G","--group", required = F, default =  NULL)
# parser$add_argument("-O", "--dir", required = F, default="~/public_html/")

# args <- parser$parse_args()

args <- parser$parse_args(c("-t", "bigwig", "-f", "WangT.*"))

json.gen.dir <- function(out.name, dir, files = NULL, type, genome = NULL,
                         debug = F, group = NULL) {

  files <- files[!grepl(".json", files)] %>% .[!grepl(".tbi$", .)]
  not.found <- files[!file.exists(files)]
  if (length(not.found) > 0) {
    ######## test point
    stop(paste0("Some files were not found: \n", 
                paste0(not.found, collapse = "\n")))
  }
  
  if (type == "igv") {
    print(files)
    abaFanc::igv.hubgen(files, no.writing = F)
    return()
  }
  
  od <- paste0(dir, "/", out.name)
  if (dir.exists(od) || file.exists(od)) {
    stop(paste0("Directory ", od, " already exists. \n", 
                "Remove it or use a different -o. \n", 
                "You can also skip -o to use the default timestamp method"))
  }
  
  jsongen <- lapply(files, function(x) {
    if (type == "ext") {
      type <- get.type(x)
    }
    
    dir.create(od, showWarnings = F, recursive = T)
    system(paste0("ln -s ", normalizePath(x), " ", 
                  normalizePath(od), "/"))
    
    x <- basename(x)
    url <- x
    
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
  
  json.name <- "files.json"
  json.file <- paste0(od, "/", json.name)
  write(json, json.file)
  
  ### note: we need to make sure that the links are actually there!
  if (debug == T)
    return(json)
  else
    return()
}

get.type <- function(x) {
  # TODO: check if the files are zipped!!
  
  lookup <- c(bw = "bigwig", bigwig = "bigwig", bigWig = "bigwig", 
              bdg = "bedgraph", bedgraph = "bedgraph", bedGraph = "bedgraph", bg = "bedgraph",
              methylC = "methylC",
              bed = "bed", narrowPeak = "bed",  bam = "bam", lr = "longrange", cat = "categorical",
              hic = "hic", cool = "cool", qbed= "qbed",
              align = "genomealign", genomeAlign = "genomealign")
  ext <- sub(".gz$","",basename(x)) %>% tools::file_ext()
  type <- lookup[ext]
  if (sum(is.na(type)) != 0) {
    warning(paste0("The track type of these files cannot be recognized from extension: \n",
                   paste0(x[is.na(type)], collapse = "\n")))
  }
  return(type)
}

json.gen.dir(dir = args$tmp, files = args$files, prefix = args$prefix,
             type = args$type, filter.exp = NULL, json.name = NULL,
             genome = args$genome,
             recursive = F, strip.dir = args$strip, group = args$group)
