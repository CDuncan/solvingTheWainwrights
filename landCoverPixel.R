library(tidyverse)
library(rgdal)
library(raster)
library(ggplot2)
library(marmap)
library(grid)
library(sf)

lakeShape <-
  shapefile("shape/LDNPA_Boundary/LDNPA_Boundary.shp") %>%
  st_as_sf()

landCover <-
  shapefile("landCover/vector/vector.shp") 
landCover <- landCover %>%
  st_as_sf()
landCover2 <- landCover %>%
  mask(x = ., mask = lakeShape)
  crop(extent(lakeShape))

  
  st_read("landCover/LCM2015_GB.gdb") %>%
  crop(extent(lakeShape))




landCover <- 
  raster("landCover/lcm2015gb25m.tif") %>%
  crop(extent(lakeShape)) %>% 
  projectRaster(crs = "+init=epsg:4326",method="ngb") %>% 
  rasterToPoints() %>%
  as_tibble() %>%
  rename(
    Longitude = x,
    Latitude  = y,
    LandCover = lcm2015gb25m) %>%
  mutate(
    Longitude = round(Longitude*1e3,0),
    Latitude = round(Latitude*1e3,0),
    LandCover = as_factor(LandCover))

source('D:/University/2019-20/Wainwrights/travelleR/geoTSP.R', echo=TRUE)

colourList <- read_csv("landCover/colourList.csv") %>%
  pull(Hex)

# Plotting ----


mapPlot<-ggplot(data=landCover, aes(y=Latitude, x=Longitude))+
  geom_raster(aes(fill=LandCover))+
  scale_fill_manual(values=colourList) +
  geom_point(data=sites,
             aes(y=latitude, x=longitude),
             color="black",
             size=1,
             shape=17)+
  theme_light()+  
  coord_equal()+
  theme(axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16, angle=90),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "right",
        legend.key = element_blank(),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))+
  labs(fill = "Land Type", x = "Longitude", y = "Latitude") +
  scale_x_continuous(labels=function(x)x*1e-3)+
  scale_y_continuous(labels=function(x)x*1e-3)

fileName = paste0("map/mapPlot_LC_","191001",".png")
ggsave(file=fileName)


