# Gib Hemani
# After liftOver the positions of the SNPs in the data should match the positions in the reference
# However, some of the SNP IDs may have changed

#R --no-save --args ${chrdata}.bim ${refroot}.markers ${chrdata}.newpos < ${rs_updateR}


args <- commandArgs(T)
bimfile <- paste(args[1], ".orig-snp-ids", sep="")
reffile <- args[2]
outbim <- args[1]
outname <- args[3]

bim <- read.table(bimfile)
ref <- read.table(reffile, header=T)

ref$index <- 1:nrow(ref)
bim$index <- 1:nrow(bim)


names(ref) <- c("SNP", "pd", "a1", "a2", "afr.aaf", "amr.aaf", "asn.aaf", "eur.aaf", "afr.maf", "amr.maf", "asn.maf", "eur.maf", "index")
names(bim) <- c("chr", "SNP", "gd", "pd", "a1", "a2", "index")
dim(ref)
dim(bim)

ref <- subset(ref, !duplicated(pd))
dim(ref)
ref <- subset(ref, !duplicated(SNP))
dim(ref)

table(bim$SNP %in% ref$SNP)
table(ref$SNP %in% bim$SNP)

table(bim$pd %in% ref$pd)

bim2 <- merge(bim, ref, by="pd", all.x=T)
bim2 <- bim2[order(bim2$index.x), ]

index <- !is.na(bim2$SNP.y)
bim2$SNP <- as.character(bim2$SNP.x)
bim2$SNP[index] <- as.character(bim2$SNP.y[index])

with(bim2, table(as.character(SNP.x) == as.character(SNP.y)))

dat <- subset(bim2, select=c("chr", "SNP", "gd", "pd", "a1.x", "a2.x"))

write.table(format(dat, scientific=F), file=outbim, row=F, col=F, qu=F)


# SNPs absent from reference chromosome

missingsnps <- as.character(dat$SNP[! dat$SNP %in% ref$SNP])
if(length(missingsnps) > 0)
{
	write.table(missingsnps, file=paste(outname, ".missingsnps", sep=""), row=F, col=F, qu=F)
	dat <- subset(dat, ! SNP %in% missingsnps)
}


# SNPs in the wrong position, ignore order this will be handled by plink

dat$SNP <- as.character(dat$SNP)
ref$SNP <- as.character(ref$SNP)
a <- merge(dat, ref, by="SNP", all.x=T)
a <- a[order(a$pd.x), ]

stopifnot(all(a$SNP == dat$SNP))
stopifnot(all(!is.na(a$SNP)))

b <- subset(a, !duplicated(SNP), select=c(SNP, pd.y))
write.table(b, outname, row=F, col=F, qu=F)

# now run plink --update-map
