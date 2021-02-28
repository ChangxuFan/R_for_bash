# this is to convert my .prox format into Xianglin's gene_density matirx format (the one starting with "3_"). details in :/scratch/yliang/pipelines/Bing_pipeline_2015/readme
# "3_" basically means considering the TSS of coding genes and isoforms.
# takes in 10kb level prox files.
# note there is no chr Y
# it takes in 3 files: ${genome}_{resolution}_bins.prox, ${genome}.chrom.sizes and resolution.
library(stringr)
library(dplyr)
library(reshape2)
args = commandArgs(trailingOnly=TRUE)
res <- args[3] %>% as.numeric()
# process the prox file and take the conventional genomes only:
prox = read.table(args[1], as.is = T, sep="\t") %>% 
filter(grepl("chr[^MY]{1,2}$", V1)) %>% 
mutate(V1 = sub("chrX", "chr0", V1)) %>%
mutate(V1 = sub("chr(.+)", "\\1", V1) %>% as.numeric()) %>% 
mutate(V1 = ifelse('=='(V1, 0), max(V1)+1, V1)) %>%
mutate(n.tss = strsplit(V4, ",") %>% sapply(length) )%>% 
rename(chr=V1, left=V2, right=V3) %>% select(chr, left, right, n.tss)
#head(prox)

chrs <- prox$chr %>% unique() %>% sort()
print(chrs)

chr1_size = read.table(args[2], as.is = T, sep="\t") %>% filter(V1 == "chr1") %>% pull(V2)
#print(chr1_size)
n.bins = (ceiling(chr1_size/1000000) * 1000000)/res
frame <- lapply(chrs, function(x) {
	data.frame(chr = rep(x, n.bins+1), left = res*(0:n.bins), right= res*(0:n.bins + 1) -1, stringsAsFactors = F)
	})

# here I added several more than I actually need. But Xianglin says that they are all 0's so it should be fine.
frame <- Reduce(rbind, frame)
#head(frame)
density.mat <- left_join(frame, prox) %>% 
mutate(n.tss = ifelse(is.na(n.tss), 0, n.tss)) %>% select(chr, left, n.tss) %>%
acast(left~chr)

write.table(density.mat, paste0(args[1], ".matrix"), 
	quote = FALSE, row.names = F, col.names = F, sep = "\t")
