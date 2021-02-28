# TE incidences input file format: "TE name"\t"start pos on consensus"\t"end pos on consensus"\n"alignment score
# I hereon refer to it as the conss file.
# consensus file format: fasta
# the first argument passed in should be the name of the file containing the consensus.
# the second argument passed in shoudl be the name fo the file containing the incidence of the TE.
ARG <- commandArgs(trailingOnly=TRUE)
conss.file <- ARG[1]
#conss.file <- "MLT1K-consensus.fasta"
conss <- read.table(conss.file, as.is = TRUE,header = FALSE, sep = "\n")
conss.name <- conss$V1[1]
conss.sequence <- paste(conss$V1[-1], collapse = "")
conss.length <- nchar(conss.sequence)
#
ori <- ARG[2]
# ori <- "3-307_MLT1K.conss"
ori <- read.table(ori, as.is = TRUE)
#ori$num <- 1:nrow(ori)
ori$V2 <- as.integer(ori$V2)
ori$V3 <- as.integer(ori$V3)
ori$V4 <- as.numeric(ori$V4)
ori <- arrange(ori, desc(V4))
ori$num <- 1:nrow(ori)
ori.list <- split( ori , f = ori$num )
cvtd <- lapply(X = ori.list, FUN = function (x) {
  #str(x)
  pre <- paste0(rep("-",x$V2-1),collapse = "")
  sequ <- substr(conss.sequence, start = x$V2, stop = x$V3)
  post <- paste0(rep("-",conss.length-x$V3),collapse = "")
  full <- paste0(pre,sequ,post)
  header <- paste0(">",x$V1,"_", x$num,"_",x$V4)
  fasta <- data.frame(V1=c(header, full))
}) 
cvtd <- do.call(rbind.data.frame, cvtd)
final <- do.call(rbind.data.frame, list(cvtd, conss.name, conss.sequence))
write.table(final, file = paste0(conss.name,".palg"),quote = FALSE, row.names = FALSE, col.names = FALSE)