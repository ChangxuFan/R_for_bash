# this script is to convert ucsc formatted chrom.sizes files into a format that is friendly to higlass. 
# $1: path to a chrom.sizes file
# $2: path to a new chrom.sizes file in higlass format.
library(dplyr)
args = commandArgs(trailingOnly=TRUE)
read.table(args[1], as.is = T) %>% 
filter(grepl("chr.{1,2}$", V1)) %>% 
mutate(V1 = sub("chrX", "chr80", V1)) %>%
mutate(V1 = sub("chrY", "chr81", V1)) %>%
mutate(V1 = sub("chrM", "chr82", V1)) %>%
mutate(chr = sub("chr(.+)", "\\1", V1) %>% as.numeric()) %>%
arrange(chr) %>% 
select(V1, V2) %>% 
mutate(V1 = sub("chr80", "chrX", V1)) %>%
mutate(V1 = sub("chr81", "chrY", V1)) %>%
mutate(V1 = sub("chr82", "chrM", V1)) %>%
write.table(args[2], quote = FALSE, row.names = F, col.names = F, sep = "\t")
