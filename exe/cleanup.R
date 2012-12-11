# R --no-save --args plink stem 

args <- commandArgs(T)
plink <- args[1]
stem <- args[2]
bimfile <- paste(stem, ".bim", sep="")

bim <- read.table(bimfile)

bim$V1 <- as.character(bim$V1)
bim$V2 <- as.character(bim$V2)
bim$V4 <- as.character(bim$V4)

dups <- bim$V2[duplicated(bim$V2)]

library(plyr)

a <- ddply(bim, "V1", function(x) { x <- transform(x); x[duplicated(x$V4), ] })
dups <- unique(c(as.character(a$V2), dups))

length(dups)

write.table(dups, paste(bimfile, ".cleanup", sep=""), row=F, col=F, qu=F)

cmd <- paste(plink, " --noweb --bfile ", stem, " --exclude ", bimfile, ".cleanup --make-bed --out ", stem, sep="")

system(cmd)



