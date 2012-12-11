# R --no-save --args 

interval <- as.numeric(commandArgs(T)[1])
size <- as.numeric(commandArgs(T)[2])
outfile <- commandArgs(T)[3]

# Split into 'interval' size spaces

first <- seq(1, size, interval)
first[length(first)] <- size + 1
last <- first[-1] - 1

nsec <- length(first) - 1

coord <- cbind(1:nsec, first[-(nsec+1)], last)
write.table(format(coord, scientific=F, trim=T), file=outfile, row=F, col=F, qu=F)
