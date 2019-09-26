library(rgdal)  
library(raster) 
library(tidyverse)

selectedCells <- 
  read_csv("asc/selectedCells.csv") %>%
  pull(cellName) %>%
  paste(.,collapse = '|')

# make a list of file names, perhaps like this:  
f <- 
  list.files(path="asc/Extracted",pattern = ".asc",full.names = T) %>% 
  as_tibble() %>%
  filter(str_detect(value,selectedCells)) %>%
  pull(value)

# turn these into a list of RasterLayer objects  
r <- 
  lapply(f, raster) %>%
  do.call("merge",.) %>%  # as you have the arguments as a list call 'merge' with 'do.call'  
  writeRaster("asc/mapMerge.asc")  #Write Ascii Grid  