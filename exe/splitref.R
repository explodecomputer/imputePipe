# Split into 'interval' size spaces
# If there are large gaps then omit those sections

findGaps <- function(position, maxint)
{
	d <- diff(position)
	splits <- c(which(d > maxint), length(position))
	nsplits <- length(splits)
	if(nsplits == 1)
	{
		return(list(position))
	} else {
		l <- list()
		j <- 1
		for(i in 1:nsplits)
		{
			l[[i]] <- position[j:(splits[i])]
			j <- splits[i]+1
		}
		return(l)
	}
}

makeSplitsDistance <- function(position, interval)
{
	first <- position[1]
	last <- position[length(position)]
	if((last-first) <= interval)
	{
		print("here")
		coord <- matrix(c(first, last), 1, 2)
		return(coord)
	}
	s1 <- seq(first, last, interval)
	s1[length(s1)] <- last + 1
	s2 <- s1[-1] - 1
	nsec <- length(s1) - 1
	coord <- cbind(s1[-(nsec+1)], s2)
	return(coord)
}

makeSplitsSnps <- function(position, interval)
{
	first <- 1
	last <- length(position)
	if(last <= interval)
	{
		print("here")
		coord <- matrix(c(position[first], position[last]), 1, 2)
		return(coord)
	}
	s1 <- seq(first, last, interval)
	s1[length(s1)] <- last + 1
	s2 <- s1[-1] - 1
	nsec <- length(s1) - 1
	coord <- cbind(position[s1[-(nsec+1)]], position[s2])
	return(coord)
}


checkCoord <- function(coord, legend)
{
	a <- array(0, nrow(coord))
	for(i in 1:nrow(coord))
	{
		a[i] <- nrow(subset(legend, position >= coord[i,2] & position <= coord[i,3]))
		if(i != nrow(coord))
		{
			stopifnot(coord[i,3] < coord[i+1,2])
		} else {
			stopifnot(coord[i,3] == legend$position[nrow(legend)])
		}
	}
	print(a)
	stopifnot(sum(a) == nrow(legend))
}


##################################################

library(plyr)

legendfile <- commandArgs(T)[1]
interval <- as.numeric(commandArgs(T)[2])
type <- commandArgs[3]
maxinterval <- commandArgs[4]
outfile <- commandArgs(T)[5]


# # Examples
# legendfile <- "ALL.chr22.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.nosing.legend.gz"

# interval <- 500000
# type <- "Distance"
# maxinterval <- 100000


# interval <- 1000
# type <- "Snps"
# maxinterval <- 100000


##################################################

legend <- read.table(legendfile, he=T, colClasses=c("character", "numeric", rep("character", 12)))[,1:2]
position <- findGaps(legend$position, maxinterval)
length(position)
lapply(position, head)
lapply(position, length)

l <- list()
for(i in 1:length(position))
{
	func <- get(paste("makeSplits", type, sep=""))
	l[[i]] <- func(position[[i]], interval)
}
coord <- do.call("rbind", l)
coord <- cbind(1:nrow(coord), coord)

checkCoord(coord, legend)

coord <- cbind(1:nsec, first[-(nsec+1)], last)
write.table(format(coord, scientific=F, trim=T), file=outfile, row=F, col=F, qu=F)
