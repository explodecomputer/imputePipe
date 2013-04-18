args <- commandArgs(T)

dat <- read.table(args[1], colClasses=c("numeric", "numeric", "character", "character", "character"))
nrow(dat)

index <- dat$V4 %in% c("A", "C", "T", "G") & dat$V5 %in% c("A", "C", "T", "G")
dat2 <- subset(dat, index)
nrow(dat2)

write.table(dat2[, 1:2], file=paste(args[1], "_keep", sep=""), row=F, col=F, qu=F)
