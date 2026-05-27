git add .
git commit -m "start"          
git push

#check colum names for HoneyChrome for Autospectral analysis

library(flowWorkspace)
library(ggplot2)
library(ggcyto)
library(flowGate)
library(openCyto)

remotes::install_github("DrCytometer/AutoSpectral")
remotes::install_github("DrCytometer/AutoSpectralRcpp")

library(AutoSpectral)
library(AutoSpectralRcpp)

