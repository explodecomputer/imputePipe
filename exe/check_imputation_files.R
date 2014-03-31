for(i in 1:23)
{
	rtdr <- paste("~/imputePipe/data/imputed/chr", i, sep="")
	sp <- read.table(paste(rtdr, "/split", i, ".txt", sep=""))
	for(j in 1:nrow(sp))
	{
		bed <- paste(rtdr, "/ALSPAC", i, "_", j, ".bed", sep="")
		gz <- paste(rtdr, "/ALSPAC", i, "_", j, ".gz", sep="")
		haps <- paste(rtdr, "/ALSPAC", i, "_", j, "_haps.gz", sep="")
		if(!file.exists(bed)) print(bed)
		if(!file.exists(gz)) print(gz)
		if(!file.exists(haps)) print(haps)
	}
}


# 3 12
# 3 26
# 3 35

# 5 8

# - 9 9

# 12 5
# 16 10
# - 21 1
