# R --no-save --args newsnplist${chr}.txt strands${chr}.markers ${chrdata}_mod.markers < ${modmarkersR}

args <- commandArgs(T)

trufile <- args[1]
allfile <- args[2]
outfile <- args[3]

trusnps <- read.table(trufile, skip=1)
allsnps <- read.table(allfile)

trusnps$index <- 1:nrow(trusnps)
a <- merge(trusnps, allsnps, by="V1")
a <- a[order(a$index), ]

a <- subset(a, select=c("V1","V2","V3","V4"))

write.table(a, file=outfile, row=F, col=F, qu=F)





