git add .
git commit -m "start"          
git push

# when I open the experiment in the software it give me different channels
# picture attached in the folder (Honeycom error)
#check colum names for HoneyChrome for Autospectral analysis

install.packages("remotes")
install.packages("Rcpp")

remotes::install_github("DrCytometer/AutoSpectral")
remotes::install_github("DrCytometer/AutoSpectralRcpp")

library(flowWorkspace)
library(ggplot2)
library(ggcyto)
library(flowGate)
library(openCyto)
library(tidyverse)

library(AutoSpectral)
library(AutoSpectralRcpp)

StoreLocation <-file.path("ATL")

fcsFile <- list.files(
  StoreLocation,
  pattern = "Sample\\.fcs$",
  full.names = TRUE)

fcsUnstained <- list.files(
  StoreLocation,
  pattern = "Unstained\\.fcs$",
  full.names = TRUE)

AF488_SCC <- list.files(
  StoreLocation,
  pattern = "488\\.fcs$",
  full.names = TRUE)

# now read each file to check colums

fcsFile <- read.FCS(fcsFile)
Colnames_fcsFile <- colnames(exprs(fcsFile))

fcsUnstained <- read.FCS (fcsUnstained)
Colnames_fcsUnstained <- colnames(exprs(fcsUnstained))

AF488_SCC <- read.FCS(AF488_SCC)
Colnames_AF488_SCC  <-colnames(exprs(AF488_SCC))

# compare all column names

setdiff(Colnames_fcsFile, Colnames_fcsUnstained)
#[1] "Autofluorescence_001-A" "Alexa Fluor 488-A"    

setdiff(Colnames_fcsFile, Colnames_AF488_SCC)
# [1] "Autofluorescence_001-A" "Alexa Fluor 488-A"   

setdiff(Colnames_fcsUnstained, Colnames_AF488_SCC)
# character(0)

# so the actual sample file has 2 more autofourescence and the name of the flourocrome which in unstained and single color control will
#be just the raw data.
#so can we get rid of AF and then match AF488 with B2?
#just raw files in this software?


#so cannot we do something like this? were we merge the data?

ParameterUpdate <- function(flowFrame, NewColumns){
    NewColumnLength <- ncol(NewColumns)
    NewColumnNames <- colnames(NewColumns)
    OldParameters <- pData(parameters(flowFrame))
    NewParameter <- max(as.integer(gsub("\\$P", "", rownames(OldParameters)))) + 1
    NewParameter <- seq(NewParameter, length.out = NewColumnLength)
    NewParameter <- paste0("$P", NewParameter)
    
    UpdatedParameters <- do.call(rbind, lapply(NewColumnNames, function(i){
                        vec <- NewColumns[,i]
                        rg <- range(vec)
                        data.frame(name = i, desc = NA, range = diff(rg) + 1, minRange = rg[1], maxRange = rg[2])
                    }))
    rownames(UpdatedParameters) <- NewParameter
    return(UpdatedParameters)
}

raw_channels <- c(
  grep("^UV[0-9]+ .*\\-A$", Colnames_fcsFile, value = TRUE),
  grep("^V[0-9]+ .*\\-A$", Colnames_fcsFile, value = TRUE),
  grep("^B[0-9]+ .*\\-A$", Colnames_fcsFile, value = TRUE),
  grep("^YG[0-9]+ .*\\-A$", Colnames_fcsFile, value = TRUE),
  grep("^R[0-9]+ .*\\-A$", Colnames_fcsFile, value = TRUE))

#subset all flowFrames identically
fcsFile_raw <- fcsFile[, raw_channels]

fcsUnstained_raw <- fcsUnstained[, raw_channels]

AF488_SCC_raw <- AF488_SCC[, raw_channels]