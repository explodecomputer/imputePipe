args <- commandArgs(T)
rootname <- args[1]
plink <- args[2]

bim <- read.table(paste(rootname, ".bim", sep=""), colClasses=c("character", "character", "numeric", "numeric", "character", "character"))

names(bim) <- c("chr", "snp", "gd", "pd", "a1", "a2")


index <- bim$snp == "."
print(sum(index))
bim$snp[index] <- with(bim, paste("chr", chr, ":", pd, sep=""))


dups <- unique(bim$snp[duplicated(bim$snp)])
ndup <- length(dups)

if(ndup == 0)
{
	cat("No duplicate SNPs\n")
	q()
} else {
	cat(paste(ndup, "duplicate SNPs\n"))
}

rename.duplicate <- function (x, sep = "_dup", verbose = FALSE) 
{
	x <- as.character(x)
	duplix <- duplicated(x)
	duplin <- x[duplix]
	ix <- numeric(length = length(unique(duplin)))
	names(ix) <- unique(duplin)
	retval <- numeric(length = length(duplin))
	for (i in 1:length(duplin)) {
		retval[i] <- ix[duplin[i]] <- ix[duplin[i]] + 1
	}
	retval <- retval + 1
	x[duplix] <- paste(duplin, retval, sep = sep)
	if (verbose) {
		message(sprintf("%i duplicated names", length(duplin)))
	}
	return(list(new.x = x, duplicated.x = duplin))
}

bim$snp <- rename.duplicate(bim$snp, sep="_DUPLICATED")[[1]]
write.table(format(bim, scientific=F), file=paste(rootname, ".bim", sep=""), row=F, col=F, qu=F)

remove <- bim$snp[grep("DUPLICATED", bim$snp)]

write.table(remove, file=paste(rootname, ".duplicatesnps", sep=""), row=F, col=F, qu=F)

(cmd <- paste(plink, " --noweb --bfile ", rootname, " --exclude ", paste(rootname, ".duplicatesnps", sep=""), " --make-bed --out ", rootname, sep=""))

system(cmd)

