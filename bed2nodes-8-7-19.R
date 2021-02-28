# local background generation 
# from full.ID to background bins.
print("this script takes in only the <filename>.bed; the 5th column of the file should be full graph ID such as 3~307")
ARG <- commandArgs(trailingOnly=TRUE)
indir <- ARG[1]
bed <- read.table(paste0(indir,".bed"), as.is = TRUE)
SIP.nodes.df <- readRDS("~/R_objects/SIP_nodes_df.Rds")
#head(bed)
#head(SIP.nodes.df)
nodes <- filter(SIP.nodes.df, full.ID %in% bed$V5)
head(nodes)
nodes <- nodes$bins
nodes <- unique(nodes)
#print(nodes)
write.nodes <- data.frame(chr=sub("(.*):(.*)", "\\1", nodes), left =as.numeric(sub("(.*):(.*)", "\\2", nodes)),
                          right=as.numeric(sub("(.*):(.*)", "\\2", nodes))+4999)
write.table(write.nodes, paste0(indir, ".nodes"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE )
