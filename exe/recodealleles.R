# recode alleles from 1234 to acgt

bimname <- commandArgs(T)[1]

system(paste("cp ", bimname, " ", bimname, ".original", sep=""))

bim <- read.table(bimname)

bim$V5 <- as.factor(bim$V5)
bim$V6 <- as.factor(bim$V6)

levels(bim$V5) <- c("A", "C", "G", "T")
levels(bim$V6) <- c("A", "C", "G", "T")

write.table(bim, file=bimname, row=F, col=F, qu=F)


