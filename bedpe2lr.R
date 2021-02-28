#!/opt/apps/R/3.6.1/bin/Rscript
library(dplyr)
options(stringsAsFactors = F)
options(scipen = 99)
args <- commandArgs(trailingOnly=TRUE)
bedpe <- args[1]
source("/bar/cfan/R_packages/scFanc/R/objects_link.R")

bedpe.2.browser(bedpe = bedpe, filter = T, pos.only = T)
