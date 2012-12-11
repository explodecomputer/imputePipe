# R --no-save --args ${chrdata}.bim ${refgmap} < ${genetdistR}

# Match genetic distances to physical distances in bim
# discard positions with missing values (.bim.nogenet)

bimfile <- commandArgs(T)[1]
genfile <- commandArgs(T)[2]

bim <- read.table(bimfile)
gen <- read.table(genfile, header=T)

a <- merge(bim, gen, by.x="V4", by.y="position", all.x=T)
a <- a[order(a$V4),]

index <- is.na(a$Genetic_Map.cM.)
a$Genetic_Map.cM.[index] <- 0
a$Genetic_Map.cM. <- a$Genetic_Map.cM. / 100
b <- a$V2[index]

write.table(b, file=paste(bimfile, ".nogenet", sep=""), row=F, col=F, qu=F)

write.table(subset(a, select=c(V1, V2, Genetic_Map.cM., V4, V5, V6)), file=bimfile, row=F, col=F, qu=F)

