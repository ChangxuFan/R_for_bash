# this file is to generate chrom_split files to match Xianglin's matlab scripts for compartment calling.
# it takes in ${genome}.cytoband.txt
library(dplyr)
args = commandArgs(trailingOnly=TRUE) 
read.table(args[1], as.is = T, sep="\t") %>% 
filter(grepl("chr[^MY]{1,2}$", V1)) %>% filter(grepl("^q", V4)) %>% 
group_by(V1) %>% summarise(centromere = min(V2)) %>%
mutate(V1 = sub("chrX", "chr0", V1)) %>% 
mutate(chr = as.numeric(sub("chr(.+)", "\\1", V1))) %>%
mutate(chr = ifelse('=='(chr, 0), max(chr)+1, chr)) %>%
select(chr, centromere) %>% arrange(chr) %>%
write.table(paste0(sub("(.+)\\.cytoBand\\.txt","\\1", args[1]), ".chrom.split"), quote = FALSE, row.names = F, col.names = F, sep = "\t")