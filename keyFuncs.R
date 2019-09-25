
convBNGtoGeo <- function(elevationMap) {
  # Would be nice to be able to use pipes here
  crs(elevationMap) <- "+init=epsg:27700" #Define coordinate reference system for raster
  projectRaster(elevationMap, crs= "+init=epsg:4326" ) }



