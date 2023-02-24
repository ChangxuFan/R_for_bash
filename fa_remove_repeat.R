#!/opt/apps/R/3.6.1/bin/Rscript
source("~/R_packages/common/base.R")

in.fas <- commandArgs(trailingOnly = T)
lapply(in.fas, function(in.fa) {
	abaFanc2::fa.remove.repeat(in.fa)
	})
