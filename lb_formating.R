print("From R: input should be _lb_LR.pre file.") 
ARG <- commandArgs(trailingOnly=TRUE)
inn <- read.table(ARG[1], as.is=TRUE)
inn <- inn %>% group_by(V1, V2, V3, V4) %>% summarise(V5=paste0(V5,collapse = ","))
write.table(inn,ARG[2], sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE )
