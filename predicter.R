#!/usr/bin/env Rscript 
# Subscript used for prediction
options(warn=-1)
suppressMessages(suppressWarnings(require(randomForest)))


args <- commandArgs(TRUE)
IMAGE <- args[1]
MODEL <- args[2]
OUTname <- args[3]



load(MODEL)
nuovi <- read.csv(IMAGE, header = F)
OUT <- as.data.frame(matrix(ncol = 2, nrow = nrow(nuovi)))

for (row in 1:nrow(nuovi)){
  OUT[row, 1] <- as.character(nuovi[row, 1])
  OUT[row, 2] <- as.character(predict(RF.mod, newdata = nuovi[row,]))
}

write.csv(OUT, file = OUTname, quote = F, col.names = F, row.names = F)