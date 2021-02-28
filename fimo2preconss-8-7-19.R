# R script developed to parse the returned results of fimo.tsv
print("Input of this R script: 1. the directory to fimo.tsv; 2. the cut off of pvalue you need; 3. the interacting group you want to look at, such as 3~307 (enter all to look at all of them)")
ARG <- commandArgs(trailingOnly=TRUE)
dir <- ARG[1]
p.cutoff <- as.numeric(ARG[2])
graph <- ARG[3]
print(ARG)
##dir <- "./"
##p.cutoff <- 0.0001
fimo <- read.table(file = paste0(dir,"/fimo.tsv"), as.is = TRUE,header = TRUE)
# generate pre-conss format 

fimo$chr <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\4",x=fimo$sequence_name)
fimo$left <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\5",x=fimo$sequence_name)
fimo$right <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\6",x=fimo$sequence_name)
fimo$TE <- sub(pattern = "(.)~(.*)\\|(.*)::(.*):(.*)-(.*)", "\\3",x=fimo$sequence_name)
fimo$sample <- sub(pattern = "(.)~(.*)\\|(.*)::(.*)", "\\1",x=fimo$sequence_name)
fimo$ID.in.sample <- sub(pattern = "(.)~(.*)\\|(.*)::(.*)", "\\2",x=fimo$sequence_name)
fimo$full.ID <- paste0(fimo$sample, "~", fimo$ID.in.sample)
fimo$location <- sub(pattern = "(.)~(.*)\\|(.*)::(.*)", "\\4",x=fimo$sequence_name)
fimo <- fimo %>% arrange(desc(score)) %>% filter(p.value <= p.cutoff) 
#print(fimo$full.ID)
if (graph != "all") fimo <- filter(fimo, full.ID==graph)
#print(fimo)
preconss <- fimo[,c("chr","left","right","TE", "start", "stop", "score")]
head(preconss)
write.table(preconss, paste0(dir,"/fimo.preconss"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE )
