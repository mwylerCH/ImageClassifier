#!/usr/bin/env Rscript 
# Subscript used for training
suppressMessages(suppressWarnings(require(randomForest)))
options(warn=-1)

args <- commandArgs(TRUE)
IMAGE <- args[1]
CLASS <- args[2]
OUT <- args[3]

# read in data
tabella <- read.csv(IMAGE, header = F)
colnames(tabella)[1] <- 'Image'

# read in classification
classified <- read.csv(CLASS, header = F)
colnames(classified) <- c('Image', 'classification')

trainer <- merge(classified, tabella)
trainer$Image <- NULL

# remove columns without variation
variation <- apply(trainer[2:ncol(trainer)], 2, var)
colKeep <- names(variation[variation > 0])
trainer <- trainer[, c('classification', colKeep)]

# make model
MTRY <- sqrt(ncol(trainer))
RF.mod <- randomForest(classification~. , data = trainer, ntree=1000, mtry = MTRY, importance = T, replace = F)

save(RF.mod, file = OUT)
