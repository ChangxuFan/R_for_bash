#!/opt/apps/R/3.6.1/bin/Rscript
for (pkg in c("dplyr", "argparse", "GenomicRanges", "rtracklayer", "parallel")) {
    suppressMessages(library(pkg, character.only = T))
}
options(stringsAsFactors = F)

parser <- argparse::ArgumentParser(add_help = T)
parser$add_argument("-i", "--in.bw", required = T, nargs = "+")
parser$add_argument("-o", "--out.bw", required = F, default = NULL, nargs = "+")
parser$add_argument("-f", "--factor", required = T, nargs = "+",
    help = paste0(
        "either passed as numbers with each number corresponding to a input bw file, ",
        "or passed as one text file with each scaling factor on a line"
    )
    )
parser$add_argument("-t", "--threads", required = F, default = 1, type = "integer")

args <- parser$parse_args()

safelapply <- function(..., threads = 1, preschedule = FALSE, stop = T) {
    if (tolower(.Platform$OS.type) == "windows") {
        threads <- 1
    }
    if (threads > 1) {
        o <- mclapply(..., mc.cores = threads, mc.preschedule = preschedule)
        errorMsg <- list()
        for (i in seq_along(o)) {
            if (inherits(o[[i]], "try-error")) {
                capOut <- utils::capture.output(o[[i]])
                capOut <- capOut[!grepl(
                    "attr\\(\\,|try-error",
                    capOut
                )]
                capOut <- head(capOut, 10)
                capOut <- unlist(lapply(capOut, function(x) {
                    substr(
                        x,
                        1, 250
                    )
                }))
                capOut <- paste0("\t", capOut)
                errorMsg[[length(errorMsg) + 1]] <- paste0(c(paste0(
                    "Error Found Iteration ",
                    i, " : "
                ), capOut), "\n")
            }
        }
        if (length(errorMsg) != 0) {
            errorMsg <- unlist(errorMsg)
            errorMsg <- head(errorMsg, 50)
            errorMsg[1] <- paste0("\n", errorMsg[1])
            if (stop == T) {
                  stop(errorMsg)
              } else {
                Warning(errorMsg)
            }
        }
    } else {
        o <- lapply(...)
    }
    o
}

bw.reNorm <- function(in.vec, out.vec = NULL, factor, threads = 1) {
    if (length(factor) == 1 && grepl("[a-zA-Z]", factor)) {
        factor <- readLines(factor)
    }
    factor <- as.numeric(factor)
    if (any(is.na(factor))) {
        stop("any(is.na(factor))")
    }

    if (length(factor) != length(in.vec)) {
        stop("length(factor) != length(in.vec)")
    }

    if (is.null(out.vec)) {
        out.vec <- tools::file_path_sans_ext(in.vec) %>%
            paste0("_reNorm_", round(factor, digits = 2), ".bw")
    }
    safelapply(seq_along(in.vec), function(i) {
        in.bw <- in.vec[i]
        out.bw <- out.vec[i]
        factor <- factor[i]
        in.gr <- rtracklayer::import.bw(in.bw)
        out.gr <- in.gr
        out.gr$score <- out.gr$score / factor
        rtracklayer::export.bw(out.gr, out.bw)
        return()
    }, threads = threads)

}

bw.reNorm(in.vec = args$in.bw, out.vec = args$out.bw, factor = args$factor, threads = args$threads)