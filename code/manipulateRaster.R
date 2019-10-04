# Join elevation raster files into single large file and reduce it
joinElevRast <- function(elevationPath){
  
  rasterPath <- paste0("rawData/elevationMap/", elevationPath)
  fileNames <- 
    list.files(path = rasterPath, pattern = ".asc", full.names = T) %>% 
    as_tibble() %>%
    pull(value)
  
  combinedRaster <- 
    lapply(fileNames, raster) %>%
    do.call("merge",.)
  crs(combinedRaster) <- "+init=epsg:27700"
  
  boundaryShape <-
    shapefile("rawData/lakeDistrictBoundary/LDNPA_Boundary.shp")
  
  outputPath <- paste0("procData/", elevationPath)
  combinedRaster <- combinedRaster %>%
    mask(x = ., mask = boundaryShape) %>%
    crop(x = ., y = extent(boundaryShape)) %>%
    #projectRaster(crs = "+init=epsg:4326") %>%
    writeRaster(filename = outputPath, format = "GTiff", overwrite=TRUE)  
}


# Reduce land cost raster
reduceLandCovRast <- function(landCoverPath){
  
  rasterPath <- paste0("rawData/landCoverMap/",landCoverPath,".tif")
  
  boundaryShape <-
    shapefile("rawData/lakeDistrictBoundary/LDNPA_Boundary.shp")

  outputPath <- paste0("procData/",landCoverPath)
  maskedRaster <- 
    raster(rasterPath, crs = "+init=epsg:27700") %>%
    mask(x = ., mask = boundaryShape) %>%
    crop(x = ., y = extent(boundaryShape)) %>%
    #projectRaster(crs = "+init=epsg:4326") %>%
    writeRaster(filename = outputPath, format = "GTiff", overwrite=TRUE)  
}


createLandCover_ElevationRaster <- function(elevationPath, landCoverPath, outputName){

  elevationRasterPath <- paste0("procData/",elevationPath,".tif")
  elevationRaster <- raster(elevationRasterPath)
  
  landCoverRasterPath <- paste0("procData/",landCoverPath,".tif")
  landCoverRaster <- raster(landCoverRasterPath)
  
  #elevationRaster <- disaggregate(elevationRaster, fact=c(2,2), method='bilinear')
  landCoverRaster <- disaggregate(landCoverRaster, fact=c(5,5))
  crs(elevationRaster) <-crs(landCoverRaster)

  
  extentMap <- elevationRaster + landCoverRaster
  elevationRaster <- crop(elevationRaster, extentMap)
  landCoverRaster <- crop(landCoverRaster, extentMap)

  outputPath <- paste0("procData/", outputName)
  combinedRaster <- 
    stack(elevationRaster,landCoverRaster) %>%
    writeRaster(filename = outputPath, format = "GTiff", overwrite=TRUE)

}