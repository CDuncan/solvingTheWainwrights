library(rgdal)  
library(raster) 
library(tidyverse)

# make a list of file names, perhaps like this:  
f <-list.files(path="asc/Extracted",pattern = ".asc",full.names = T)  

f <- f %>% 
  as_tibble() %>%
  mutate(
    cell= case_when(
      str_detect(value,"NY") ~ "Max",
      TRUE ~ "Min"),
    northing=as.numeric(str_sub(value,-5,-5)),
    easting=as.numeric(str_sub(value,-6,-6)))%>%
  filter((northing <=5 & cell=="Max")|(northing >=6 & cell=="Min")) %>%
  filter(easting <=5) %>%
  pull(value)

# turn these into a list of RasterLayer objects  
r <- lapply(f, raster) 


# as you have the arguments as a list call 'merge' with 'do.call'  
x <- do.call("merge",r) 


#Write Ascii Grid  
writeRaster(x,"asc/mapMerge.asc")  
