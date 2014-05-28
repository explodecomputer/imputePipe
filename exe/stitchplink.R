
# --args split${chr}.txt stitch${chr}.txt ${targetdatadir}${chrdata}.bim ${plink} ${impdatadir}${chrdata} ${impdatadir}${plink1kg}


checkOverwrite <- function(filename, i=1)
{
	if(!file.exists(filename))
	{
		return(filename)
	} else {
		return(checkOverwrite(paste(filename, i, sep=""), i+1))
	}
}

recodeDotsBim <- function(bimfile)
{
	a <- read.table(bimfile, he=F, colClasses="character")
	names(a) <- c("chr", "snp", "gd", "pd", "a1", "a2")
	index <- a$snp == "."
	if(sum(index) == 0) return()
	cat(sum(index), "dots\n")
	a$snp[index] <- paste("chr", a$chr[index], ":", a$pd[index], sep="")
	newfile <- checkOverwrite(paste(bimfile, ".original", sep=""))
	cmd <- paste("cp ", bimfile, " ", newfile, sep="")
	system(cmd)
	write.table(a, file=bimfile, row=F, col=F, qu=F)
}

recodeDotsInfo <- function(infofile)
{
	a <- read.table(infofile, he=T, colClasses="character")
	index <- a$rs_id == "."
	if(sum(index) == 0) return()
	cat(sum(index), "dots\n")
	chr <- unique(a$snp_id)
	chr <- chr[chr != "---"]
	a$rs_id[index] <- paste("chr", chr, ":", a$position[index], sep="")
	newfile <- checkOverwrite(paste(infofile, ".original", sep=""))
	cmd <- paste("cp ", infofile, " ", newfile, sep="")
	system(cmd)
	write.table(a, file=infofile, row=F, col=T, qu=F)
}

recodeChrBim <- function(bimfile)
{
	a <- read.table(bimfile, he=F, colClasses="character")
	names(a) <- c("chr", "snp", "gd", "pd", "a1", "a2")
	index <- grep("chr", a$snp)
	if(length(index) == 0) return()
	cat(length(index), "dots\n")
	a$snp[index] <- paste("chr", a$chr[index], ":", a$pd[index], sep="")
	newfile <- checkOverwrite(paste(bimfile, ".wrong", sep=""))
	cmd <- paste("cp ", bimfile, " ", newfile, sep="")
	system(cmd)
	write.table(a, file=bimfile, row=F, col=F, qu=F)
}


args <- commandArgs(T)

splittxt   <- args[1]
stitchtxt  <- args[2]
bimfile    <- args[3]
plink      <- args[4]
inputstem  <- args[5]
outputstem <- args[6]

split <- read.table(splittxt)
bim <- read.table(bimfile)
dim(bim)

print(split)

# for every row in split check that there are supposed to be SNPs there and if so check that the output file exists
# if it is all good then add the files to the stitch dataframe

stitch <- c()

ii <- 1
for(i in 1:nrow(split))
{
	a <- sum(bim$V4 %in% split$V2[i]:split$V3[i])
	print(c(i, a))
	if(a > 0)
	{
		# check the bim, bed, fam files exist
		stopifnot(file.exists(paste(inputstem, "_", i, ".bed", sep="")))
		stopifnot(file.exists(paste(inputstem, "_", i, ".bim", sep="")))
		stopifnot(file.exists(paste(inputstem, "_", i, ".fam", sep="")))
		# recodeDotsBim(paste(inputstem, "_", i, ".bim", sep=""))
		# recodeChrBim(paste(inputstem, "_", i, ".bim", sep=""))
		# recodeDotsInfo(paste(inputstem, "_", i, "_info", sep=""))
		stitch[ii] <- i
		ii <- ii+1
	}
}

# recodeChrBim(paste(outputstem, ".bim", sep=""))
print(stitch)

# q()
# stitch together the info files
# first file is cat, rest have to have header removed
print(cmd <- paste("cat ", inputstem, "_", stitch[1], "_info > ", outputstem, "_info.txt", sep=""))
system(cmd)
for(i in 2:length(stitch)) {
	print(cmd <- paste("sed 1d ", inputstem, "_", stitch[i], "_info >> ", outputstem, "_info.txt", sep=""))
	system(cmd)
}

# create list of files to be merged by plink
filelist <- data.frame(paste(inputstem, "_", stitch, ".bed ", inputstem, "_", stitch, ".bim ", inputstem, "_", stitch, ".fam", sep=""))

print(filelist)

write.table(filelist[-1, ], stitchtxt, row=F, col=F, qu=F)

# run plink to merge files
print(cmd <- paste(plink, " --noweb --bfile ", inputstem, "_", stitch[1], " --merge-list ", stitchtxt, " --make-bed --out ", outputstem, sep=""))
system(cmd)


a <- paste(inputstem, "_", stitch, ".gz", sep="")
print(cmd <- paste("cat ", paste(a, collapse=" "), " > ", outputstem, ".gz", sep=""))
system(cmd)

a <- paste(inputstem, "_", stitch, "_haps.gz", sep="")
print(cmd <- paste("cat ", paste(a, collapse=" "), " > ", outputstem, "_haps.gz", sep=""))
system(cmd)

a <- paste(inputstem, "_", stitch, "_allele_probs.gz", sep="")
print(cmd <- paste("cat ", paste(a, collapse=" "), " > ", outputstem, "_allele_probs.gz", sep=""))
system(cmd)

# if successful then delete the other bim/bed/fam files
