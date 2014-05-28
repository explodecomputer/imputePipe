arguments <- commandArgs(T)

codefile <- arguments[1]
bimfile <- arguments[2]
chr <- arguments[3]

codes <- read.table(codefile, colClass=c("character", "numeric", "character", "character"))
index <- codes$V1 == "."
codes$V1[index] <- paste("chr", chr, ":", codes$V2[index], sep="")
dim(codes)

bim <- read.table(bimfile, colClass=c("character", "character", "numeric", "numeric", "character", "character"))
bim$code <- with(bim, paste(V2, V4))
codes$code <- with(codes, paste(V1, V2))
dim(bim)

dim(codes)

head(codes[index,])
codes <- subset(codes, code %in% bim$code)

dim(codes)

stopifnot(nrow(codes) == nrow(bim))
stopifnot(all(codes$code == bim$code))

codes$l1 <- nchar(codes$V3)
codes$l2 <- nchar(codes$V4)

index <- codes$l1 != 1 | codes$l2 != 1
index2 <- codes$l1 > codes$l2
index3 <- codes$l1 <= codes$l2 & codes$l2 != 1
index4 <- (codes$l1 == codes$l2) & codes$l1 != 1

codes$a0 <- codes$V3
codes$a1 <- codes$V4
codes$a0[index] <- "R"
codes$a1[index2] <- "D"
codes$a1[index3] <- "I"

bim$a0 <- bim$V5
bim$a1 <- bim$V6

yindex0 <- bim$a0 == "Y"
yindex1 <- bim$a1 == "Y"
zindex0 <- bim$a0 == "Z"
zindex1 <- bim$a1 == "Z"

table(yindex0)
table(yindex1)
table(zindex0)
table(zindex1)

bim$a0[yindex0] <- codes$a1[yindex0]
bim$a1[yindex1] <- codes$a0[yindex1]
bim$a0[zindex0] <- codes$a1[zindex0]
bim$a1[zindex1] <- codes$a0[zindex1]


table(bim$a0)
table(bim$a1)

write.table(subset(bim, select=c(V1, V2, V3, V4, a0, a1)), file=bimfile, row=F, col=F, qu=F)

