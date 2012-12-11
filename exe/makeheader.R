famfile <- commandArgs(T)[1]
outfile <- commandArgs(T)[2]

fam <- read.table(famfile)

nom <- as.character(fam$V2)

header <- c("marker", "AlleleA", "AlleleB", rep(nom, each=3))
header <- matrix(header, 1, length(header))

write.table(header, file=outfile, row=F, col=F, qu=F)

