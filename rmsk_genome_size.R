# a generator of genome sizes. 
print("argument: rmsk file in rmsk.simple format")
print("argument2: a random number")
print("this script is used together with ~/scripts/rmsk_genome_size.sh")
ARG <- commandArgs(trailingOnly=TRUE)
rmsk.genome.size <- function(rmsk=ARG[1], seed=ARG[2]) {
  rmsk <- read.table(rmsk, as.is = TRUE)
  colnames(rmsk) <- c("chr", "left", "right", "strand", "subfamily", "class", "family", "id")
  rmsk <- rmsk %>% group_by(chr) %>% summarise(left.min=min(left), right.max=max(right))
  #rmsk$span <- rmsk$right.max - rmsk$left.min
  write.table(rmsk, paste0("rmsk_coverage_with_N.bed", ".", seed), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
  return(NULL)
}
rmsk.genome.size()