# TE incidences input file format: "TE name"\t"start pos on consensus"\t"end pos on consensus"\t"chr of TE"\t"start site of TE on chr"\t "stop site of TE on chr"\t"alignment score"
# I hereon refer to it as the conss file.
# consensus file format: fasta
# the first argument passed in should be the name of the file containing the consensus.
# the second argument passed in shoudl be the name fo the file containing the incidence of the TE.
# the third argument should be file with two columns indicating the start and stop position of the motif on the consensus.
# the fourth argument should be the tag for output palg_color file
options(stringsAsFactors=FALSE)
ARG <- commandArgs(trailingOnly=TRUE)
conss.file <- ARG[1]
#conss.file <- "MLT1J2-consensus.fasta"
conss <- read.table(conss.file, as.is = TRUE,header = FALSE, sep = "\n")
conss.name <- conss$V1[1]
conss.sequence <- paste(conss$V1[-1], collapse = "")
conss.length <- nchar(conss.sequence)
#
ori <- ARG[2]
#ori <- "palg_color-THE1B.conss_color"
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
  return(data.frame(TE=paste0(x$V4, ":",x$V5, "-",x$V6), score=x$V7, seq=full, start=x$V8, stop=x$V9))
}) 
cvtd <- do.call(rbind.data.frame, cvtd)
combine.fasta <- function (C) {
  CC <- Reduce(paste0,strsplit(C, ""))
  D <- gsub("-","",CC)
  D[D==""] <- "-"
  return(paste0(substr(D,start=1,stop=1), collapse = ""))
}
cvtd.merge <- cvtd %>% group_by(TE) %>% summarise(score=max(score), seq=combine.fasta(seq), start=start[1], stop=stop[1]) %>% arrange(desc(score))
cvtd.merge.color <- lapply(split( cvtd.merge , f = cvtd.merge$TE ), function (x) {
  x$color <- gsub("[^-]", "G",x$seq)
  x$color <- gsub("-", "C", x$color)
  n <- nchar(x$seq)
  if (x$start-1 == 0) {
    x$before <- "Q"
  } else {
    x$before <- paste0(rep("-", x$start-1),collapse = "")
  }
  x$middle <- substr(x$color, start=x$start, stop=x$stop)
  if (n-x$stop == 0) {
    x$after <- "Q"
  } else {
    x$after <- paste0(rep("-", n-x$stop),collapse="")
  }
  x$spacer.name <- ">----"
  x$spacer <- paste0(rep("-",n),collapse = "")
  x$seq.color <- paste(c(x$before, x$middle, x$after),collapse="")
  x$seq.color <- gsub("Q", "", x$seq.color)
  x[,c("seq", "before", "middle", "after", "color","start","stop")] <- NULL
  return(x)
})
cvtd.merge.color <- Reduce(rbind, cvtd.merge.color)
# now deal with the consensus:
motif <- ARG[3]
motif <- read.table(motif, as.is = TRUE)
motif.edit <- function (x,start, stop) {
  left <- substr(x,start=1, stop =start-1)
  right <- substr(x, start=stop +1, stop = nchar(x))
  middle <- paste(rep("G",stop-start+1), collapse = "")
  return(paste(c(left,middle,right), collapse = ""))
}
conss.sequence <- gsub(".","T", conss.sequence)
for (i in 1:nrow(motif)) {
  conss.sequence <- motif.edit(conss.sequence,motif[i,1], motif[i,2])
}



if (length(unique(nchar(cvtd.merge.color$seq.color))) != 1 ) print("error: probably a bug in fasta merging: sequence not in the same length!")
cvtd.merge.color$header <- paste0(">", TE.name,"~",cvtd.merge.color$score,"~" ,cvtd.merge.color$TE)

conss <- data.frame(TE=conss.name, score=0, seq.color=conss.sequence, header=conss.name,spacer.name = ">----", spacer= paste0(rep("-",nchar(conss.sequence)),collapse = ""))
final <- rbind.data.frame(cvtd.merge.color,conss)
write.table(final[,c("header", "seq.color", "spacer.name", "spacer")], file = paste0(ARG[4],".palg_color.fa"),quote = FALSE, row.names = FALSE, col.names = FALSE,sep = "\n")

