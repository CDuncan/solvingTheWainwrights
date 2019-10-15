library(raster)
library(sf)
library(rgdal)
library(tidyverse)





# Chunk based movement ----
# Translate left and right using chunks

shiftRaster <- function(loadedRaster,shiftX,shiftY,outputFile){
  outputFile <- paste0("shiftRaster/",outputFile,"_X",shiftX,"_Y",shiftY,".tif")
  
  colCount <- ncol(loadedRaster)
  
  blocks <- blockSize(loadedRaster)
  blocks$shiftedRow <- blocks$row + shiftY
  blocks$shiftedRow[1] <- 1
  blocks$nrows[length(blocks$nrows)] <- blocks$nrows[length(blocks$nrows)] - shiftY
  
  addCol <- matrix(NA, ncol = shiftX, nrow = 1)
  
  output <- writeStart(loadedRaster, outputFile, overwrite=TRUE)
  
  for (i in 1:blocks$n){
    cat('\r',i,'/',blocks$n,"  ")
    
    blockToFrame <-
      getValues(loadedRaster, row = blocks$row[i], nrows = blocks$nrows[i]) %>% 
      matrix(ncol = colCount,  byrow = TRUE) %>%
      as.data.frame()
    
    blockToFrame <- blockToFrame %>%
      .[1:(length(.)-shiftX)] %>%
      cbind(addCol,.) 
    
    blockToFrame <- as.vector(t(blockToFrame))
    if (i == 1 & shiftY != 0)
    {blockToFrame <- c( rep(NA, shiftY*colCount),blockToFrame)}
    
    output <- writeValues(output,blockToFrame,blocks$shiftedRow[i])
    
  }
  
  output <- writeStop(output)
}


loadedMap <- raster("terr5.tif")

xy <- tibble(x = c(0,1,1,2),
             y = c(1,0,1,1))

for (i in 1:4) {
  shiftRaster(loadedRaster = loadedMap, shiftX = xy$x[i], shiftY = xy$y[i], outputFile = "shifted")
}










#addRow <- matrix(NA, nrow = shiftRow, ncol = 1)
#    head(.,n=-shiftRow) %>%
#rbind(addRow,.)



# Read neighbours ----

f4 <- function(x, filename) {
  outN <- outE <- outS <- outW <- x
  outN <- writeStart(outN, paste0(filename,"N.tif"), overwrite=TRUE)
  outE <- writeStart(outE, paste0(filename,"E.tif"), overwrite=TRUE)
  outS <- writeStart(outS, paste0(filename,"S.tif"), overwrite=TRUE)
  outW <- writeStart(outW, paste0(filename,"W.tif"), overwrite=TRUE)
  
  N <- getValues(x, row = 1, nrows = 1)
  C <- N
  S <- getValues(x, row = 2, nrows = 1)
  len <- length(C)
  W <- head(append(C,NA,0),-1)
  E <- tail(append(C,NA,len),-1)
  
  outN <- writeValues(outN, N+NA, 1)
  outS <- writeValues(outS, S, 1)
  outW <- writeValues(outW, W, 1)
  outE <- writeValues(outE, E, 1)
  
  
  for (i in 2:494) {
    cat('\r',i)
    flush.console() 
    N <- C
    C <- S
    if (i==494){ S <- S+NA }
    else { S <- getValues(x, row = i+1, nrows = 1) }
    E <- head(append(C,NA,0),-1)
    W <- tail(append(C,NA,len),-1)
    outN <- writeValues(outN, N, i)
    outS <- writeValues(outS, S, i)
    outW <- writeValues(outW, W, i)
    outE <- writeValues(outE, E, i)
  }
  outN <- writeStop(outN)
  outE <- writeStop(outE)
  outS <- writeStop(outS)
  outW <- writeStop(outW)
  return("")
}
