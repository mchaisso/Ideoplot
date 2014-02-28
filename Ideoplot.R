library(getopt)

source("/net/eichler/vol5/home/mchaisso/projects/Ideogram/Ideoplot/hg19Bands.R")

GetBands <- function(genomebands, chrom) {
  i <- which(genomebands$V1 == chrom)
  return(genomebands[i,])
}


GetMaxChromLength <- function(bands) {

  return(max(bands$V3))
}

GetBands <- function(genomebands, chrom) {
  i <- which(genomebands$V1 == chrom)
  return(genomebands[i,])
}

require(RColorBrewer)
AddHeatmap <- function(x,y, width, chrBands, heatMap, nColors) {
  pal <- rev(brewer.pal(nColors, "RdBu"))

  nElem <- length(heatMap$V1)

  x1 <- rep(x,nElem)
  x2 <- x1+width
  y1 <- y+heatMap$V2
  y2 <- y+heatMap$V3

  if (args$topdown == TRUE) {
    y1 <- yTop - y1
    y2 <- yTop - y2
  }
  rect(x1,y1,x2,y2,col=pal[heatMap$V4], border=NA)
}

DrawChromosome <- function(x,y, width, chrBands) {
  maxY <- GetMaxChromLength(chrBands)
  aceni <- which(chrBands$V5 == "acen")
  if (length(aceni) == 2) {
    allX <- c(0, 0, (width/2),0,0,0+width, 0+width,0+(width/2),0+width,0+width, 0) +x
    allY <- c(0, chrBands$V2[aceni[1]], chrBands$V3[aceni[1]],  chrBands$V3[aceni[2]], maxY, maxY, chrBands$V3[aceni[2]], chrBands$V3[aceni[1]], chrBands$V2[aceni[1]], 0,0)+y
    nPoints <- length(allX)
    x0 <- allX[1:nPoints-1]
    x1 <- allX[2:nPoints]
    y0 <- allY[1:nPoints-1]
    y1 <- allY[2:nPoints]

    if (args$topdown == TRUE) {
      y0 <- yTop - y0
      y1 <- yTop - y1
    }
    segments(x0,y0,x1,y1)
  }
}


GetByChr <- function(genomebands, chrom) {
  i <- which(genomebands$V1 == chrom)
  return(genomebands[i,])
}

ToBins <- function(hm,nBins ) {
  mx <- max(hm$V4)
  mn <- min(hm$V4)
  l <- floor(((hm$V4-mn)/(mx-mn))*nBins)+1
  res <- apply(cbind(l, rep(nBins,length(hm$V4))),1,min)
  return(res)
}

DrawAnnotation <- function(x, y, s, color) {
  plotChar <- 0
  if (args$topdown == TRUE) {
    y <- yTop - y
  }
  points(x, y, pch=as.numeric(s), col=color,cex=0.25)   
}

DrawAnnotations <- function(x,y, stripeWidths, chrAnnot) {
  if (dim(chrAnnot)[1] > 0) {
    
    tmp <- apply(chrAnnot, 1, function(r) DrawAnnotation(x+ sum(stripeWidths[0:(as.numeric(r[4])-1)]), y+((as.numeric(r[3])-as.numeric(r[2]))/2)+as.numeric(r[2]), r[5], r[6]))
  }
}


options <- matrix(c("ideobed", "i", 2, "character",
                    "heatmap", "h", 2, "character",
                    "annotate", "a", 2, "character",
                    "out", "o", 2, "character",
                    "topdown", "r", 2, "integer"), byrow=T, ncol=4)

args <- getopt(options)

bands <- hg19Bands

if (is.null(args$topdown)) {
  args$topdown <- FALSE
} else {
  args$topdown <- TRUE
}

if (is.null(args$out)) {
  outFileName <- "ideogram.pdf"
} else {
  outFileName <- args$out
}

if (is.null(args$ideobed)) {
  bands <- hg19Bands } else {
  bands <- read.table(args$ideobed)
}





if (is.null(args$heatmap) == FALSE) {
  hmap <- read.table(args$heatmap,header=F)
}



chrNames <- paste("chr",c(seq(1,22),"X"),sep="")
chrLabels <- paste(c(seq(1,22),"X", sep=""))

nChrom <- length(chrNames)
maxLength <- GetMaxChromLength(bands)

stripeWidths <- c(5,5,15,10)
stripesPerCol <- length(stripeWidths)
colWidth <- sum(stripeWidths)

nCols <- nChrom
chromStripe <- 3

colWidth <- sum(stripeWidths)
yLen <- ceiling(maxLength * 1.1)
xLen <- colWidth*nCols

chromX <- seq(0,nChrom-1)*colWidth + sum(stripeWidths[1:(chromStripe-1)])
bandByChr <- lapply(seq(1,nChrom), function(i) GetByChr(bands, chrNames[i]))

nBins <- 9

chrLen <- sapply(seq(1,nChrom), function(i) GetMaxChromLength(bandByChr[[i]]))
chromY <- rep(0.05*maxLength, nChrom)

#
# Setup output.
#
print(sprintf("opening %s", outFileName))
pdf(outFileName, width=8,height=4)
plot(c(), xlim=c(0,xLen), ylim=c(0,yLen), axes=F, xlab="", ylab="")

if (args$topdown == TRUE) {
  yTop <- 1.1*maxLength
}

#
# Plot heatmap if one is specified.
#
if (is.null(args$heatmap) == FALSE) {
  hmByChr <- lapply(seq(1,nChrom), function(i) GetByChr(hmap, chrNames[i]))

  for (i in seq(1,nChrom)) {
  
    hmByChr[[i]]$V4 <- ToBins(hmByChr[[i]], nBins)
  }

  tmp <- sapply(seq(1,nChrom), function(i) AddHeatmap(chromX[i],
                                                      chromY[i],
                                                      stripeWidths[chromStripe],
                                                      bandByChr[[i]],
                                                      hmByChr[[i]],
                                                      nBins ))
}


#
# Draw the chromosomes.
#

tmp <- sapply(seq(1,nChrom), function(i) DrawChromosome(chromX[i], chromY[i], stripeWidths[chromStripe], bandByChr[[i]]))


if (is.null(args$annotate) == FALSE) {
  annot <- read.table(args$annotate,header=F)
  annot$V2 <- as.numeric(annot$V2)
  annot$V3 <- as.numeric(annot$V3)
  annot$V4 <- as.numeric(annot$V4)

  annotByChr <- lapply(seq(1,nChrom), function(i) GetByChr(annot, chrNames[i]))
  
  tmp <- sapply(seq(1,nChrom), function(i) DrawAnnotations((i-1)*colWidth, chromY[i], stripeWidths, annotByChr[[i]]))
  
}

tmp <- sapply(seq(1,nChrom), function(i) text(chromX[i]+(stripeWidths[chromStripe]/2), 0, chrLabels[i], cex=0.5))
axisStep <- 5E7
axisPos <- seq(0, (1+ceiling(maxLength/axisStep))*axisStep, axisStep)

axis(2, at=c(1E8+chromY[1], 1E8+chromY[1]+1E8), labels=c("", ""),cex.axis=0.5, col.ticks=NA)
mtext("100Mbp", side=2,line=0, at=1.5E8+chromY[1], cex=0.5)
warnings()
dev.off()





