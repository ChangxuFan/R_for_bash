# TE incidences input file format: "TE name"\t"start pos on consensus"\t"end pos on consensus"\t"chr of TE"\t"start site of TE on chr"\t "stop site of TE on chr"\t"alignment score"
# I hereon refer to it as the conss file.
# consensus file format: fasta
# the first argument passed in should be the name of the file containing the consensus.
# the second argument passed in shoudl be the name fo the file containing the incidence of the TE.
options(stringsAsFactors=FALSE)
ARG <- commandArgs(trailingOnly=TRUE)
conss.file <- ARG[1]
# conss.file <- "MLT1K-consensus.fasta"
conss <- read.table(conss.file, as.is = TRUE,header = FALSE, sep = "\n")
conss.name <- conss$V1[1]
conss.sequence <- paste(conss$V1[-1], collapse = "")
conss.length <- nchar(conss.sequence)
#
ori <- ARG[2]
# ori <- "fimo.conss"
ori <- read.table(ori, as.is = TRUE)
#ori$num <- 1:nrow(ori)
#ori$V2 <- as.integer(ori$V2)
#ori$V3 <- as.integer(ori$V3)
#ori$V7 <- as.numeric(ori$V7)
#ori <- arrange(ori, desc(V7))
TE.name <- ori$V1[1]
ori$num <- 1:nrow(ori)
ori.list <- split( ori , f = ori$num )
cvtd <- lapply(X = ori.list, FUN = function (x) {
  #str(x)
  pre <- paste0(rep("-",x$V2-1),collapse = "")
  sequ <- substr(conss.sequence, start = x$V2, stop = x$V3)
  post <- paste0(rep("-",conss.length-x$V3),collapse = "")
  full <- paste0(pre,sequ,post)
  #header <- paste0(">",x$V1,"_", x$num,"_",x$V7)
  return(data.frame(TE=paste0(x$V4, ":",x$V5, "-",x$V6), score=x$V7, seq=full))
}) 
cvtd <- do.call(rbind.data.frame, cvtd)
combine.fasta <- function (C) {
  CC <- Reduce(paste0,strsplit(C, ""))
  D <- gsub("-","",CC)
  D[D==""] <- "-"
  return(paste0(substr(D,start=1,stop=1), collapse = ""))
}
cvtd.merge <- cvtd %>% group_by(TE) %>% summarise(score=max(score), seq=combine.fasta(seq)) %>% arrange(desc(score))
if (length(unique(nchar(cvtd.merge$seq))) != 1 ) print("error: probably a bug in fasta merging: sequence not in the same length!")
cvtd.merge$header <- paste0(">", TE.name,"~",cvtd.merge$score,"~" ,cvtd.merge$TE)

conss <- data.frame(TE=conss.name, score=0, seq=conss.sequence, header=conss.name)
final <- rbind.data.frame(cvtd.merge,conss)
write.table(final[,c("header", "seq")], file = paste0(conss.name,".palg.fa"),quote = FALSE, row.names = FALSE, col.names = FALSE,sep = "\n")
