library(tidyverse)
library(rgdal)
library(raster)
library(ggplot2)
library(marmap)
library(grid)
library(sf)
library(cptcity)

# Load ERSI ASCII grid and transform into tibble of measured elevations
SDNY <- 
  raster("asc/t50_mapMerge.asc", crs = "+init=epsg:27700") %>%
  projectRaster(crs = "+init=epsg:4326") %>%
  rasterToPoints() %>%
  as_tibble() %>%
  rename(
    Longitude = x,
    Latitude  = y,
    Elevation = t50_mapMerge) %>%
  mutate(
    Longitude = round(Longitude*1e3,0),
    Latitude = round(Latitude*1e3,0),    
    Elevation = ifelse(Elevation <= 0, -100,Elevation))



source('D:/University/2019-20/Wainwrights/travelleR/geoTSP.R', echo=TRUE)



# Plotting ----

colourSet <-rev(etopo.colors(150)[-(1:15)])[-(1:35)]

mapPlot<-ggplot(data=SDNY, aes(y=Latitude, x=Longitude))+
  geom_raster(aes(fill=Elevation))+
  scale_fill_gradientn(colours = cpt(pal="wkp_country_wiki_france"),
                       na.value = "#afdce0",
                       limits = c(-1000,1000))+
  geom_point(data=sites,
             aes(y=latitude, x=longitude),
             color="white",
             size=1,
             shape=17)+
  geom_path(data=sites,
            aes(y=latitude, x=longitude),
            color="red")+
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
  labs(fill = "Elevation (m)", x = "Longitude", y = "Latitude") +
  scale_x_continuous(labels=function(x)x*1e-3)+
  scale_y_continuous(labels=function(x)x*1e-3)

fileName = paste0("map/mapPlot_","190927",".png")
ggsave(file=fileName)




if (FALSE){
  find_cpt("jm")
  scale_fill_gradientn(
    colours=colourSet,
    na.value = "#afdce0",
    breaks=c(1,250,500,750))
}