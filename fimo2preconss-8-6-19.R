# R script developed to parse the returned results of fimo.tsv
print("Input of this R script: 1. the directory to fimo.tsv; 2. the cut off of pvalue you need")
ARG <- commandArgs(trailingOnly=TRUE)
dir <- ARG[1]
p.cutoff <- as.numeric(ARG[2])
##dir <- "./"
##p.cutoff <- 0.0001
fimo <- read.table(file = paste0(dir,"/fimo.tsv"), as.is = TRUE,header = TRUE)
# generate pre-conss format 
fimo <- fimo %>% arrange(desc(score)) %>% filter(p.value <= p.cutoff)  
fimo$chr <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\4",x=fimo$sequence_name)
fimo$left <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\5",x=fimo$sequence_name)
fimo$right <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\6",x=fimo$sequence_name)
fimo$TE <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\3",x=fimo$sequence_name)
preconss <- fimo[,c("chr","left","right","TE", "start", "stop", "score")]
head(preconss)
write.table(preconss, paste0(dir,"/fimo.preconss"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE )

