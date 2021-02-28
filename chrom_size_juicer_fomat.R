# this script is to convert ucsc formatted chrom.sizes files into a format that is friendly to juicer. It's the mainly 
# created for ~/scripts/compartment_calling/bing2015_eigen_pipeline_fanc.sh
# it takes in only the path to a chrom.sizes file
library(dplyr)
args = commandArgs(trailingOnly=TRUE)
read.table(args[1], as.is = T) %>% 
filter(grepl("chr[^M]{1,2}$", V1)) %>% mutate(chr = sub("chr(.+)", "\\1", V1)) %>%
select(chr, V1, V2) %>% 
write.table(paste0(args[1], ".juicer"), quote = FALSE, row.names = F, col.names = F, sep = "\t")
