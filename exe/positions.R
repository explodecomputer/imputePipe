# Some SNPs might not be on this chromosome
# Some might be out of order
# Most will probably have the wrong physical position


#R --no-save --args ${chrdata}.bim ${refroot}.markers ${chrdata}.newpos < ${positionsR}

args <- commandArgs(T)

datname <- args[1]
refname <- args[2]
outname <- args[3]

dat <- read.table(datname)
ref <- read.table(refname, header=T)

ref <- subset(ref, select=c(id, position, a0, a1))

# SNPs absent from reference chromosome

missingsnps <- as.character(dat$V2[! dat$V2 %in% ref$id])
if(length(missingsnps) > 0)
{
	write.table(missingsnps, file=paste(outname, ".missingsnps", sep=""), row=F, col=F, qu=F)
	dat <- subset(dat, ! V2 %in% missingsnps)
}


# SNPs in the wrong position, ignore order this will be handled by plink

dat$V2 <- as.character(dat$V2)
ref$id <- as.character(ref$id)
a <- merge(dat, ref, by.x="V2", by.y="id", all.x=T)
a <- a[order(a$V4), ]

stopifnot(all(a$V1 == dat$V1))
stopifnot(all(!is.na(a$V2)))

a <- a[, c(1,7)]
write.table(a, outname, row=F, col=F, qu=F)

# now run plink --update-map
