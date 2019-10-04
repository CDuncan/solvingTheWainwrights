##################################################
## Project: The travelling salesman goes hiking in the Lake District
## Script purpose: Main file to run subfiles
## Date: 2019-10-01
## Author: Callum Duncan
##################################################

# Load packages ----
library(tidyverse)
library(raster)
library(rgdal)
library(ggplot2)
library(grid)
library(sf)
library(geosphere)
library(TSP)

# Load functions ----
source('D:/University/2019-20/Wainwrights/hikeR/code/manipulateRaster.R', echo=TRUE)


# Create raster files ----
joinElevRast("terrain50")
reduceLandCovRast("reduced_landCover2015_25m")
createLandCover_ElevationRaster( 
  elevationPath = "terrain5",
  landCoverPath = "reduced_landCover2015_25m",
  outputName = "stack_t5-25m")

# Load stack ----

elevationRaster <- stack("procData/stack_t50-25m.tif")
names(elevationRaster) <- c("elevation","landCover")

