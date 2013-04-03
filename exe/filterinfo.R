args <- commandArgs(T)

infofile <- args[1]
bimfile <- args[2]
outfile <- args[3]

info <- read.table(infofile, header=T)
bim <- read.table(bimfile)

dim(info)
dim(bim)

info <- subset(info, !duplicated(rs_id))
table(info$rs_id == bim$V2)

removedsnps <- which(bim$V5 == "0" | bim$V6 == "0")
length(removedsnps)

write.table(bim$V2[removedsnps], file=paste(bimfile, ".removesnps", sep=""), row=F, col=F, qu=F)

info <- info[-removedsnps, ]
dim(info)

write.table(subset(info, select=c("rs_id", "info")), file=outfile, row=F, col=F, qu=F)

