library(tidyverse)
library(rgdal)
library(raster)
library(ggplot2)
library(marmap)
library(grid)

fileName = paste0("map/mapPlot_","190925",".png")

SDNY <- raster("asc/mapMerge.asc")
Klol <- convBNGtoGeo(SDNY)
#SDNY.p <- rasterToPoints(SDNY)
SDNY.p <- rasterToPoints(Klol)
map.p <-SDNY.p
df <- data.frame(map.p) %>% 
  mutate(mapMerge = case_when(
    mapMerge <= 0 ~ NA_real_,
    TRUE ~ mapMerge))
colnames(df) <- c("Long", "Lat", "Elevation")

df <- df %>% mutate(Lat=round(Lat*1e3,0),
             Long=round(Long*1e3,0))

source('D:/University/2019-20/Wainwrights/travelleR/plotPoints.R', echo=TRUE)


colourSet <-rev(etopo.colors(150)[-(1:15)])[-(1:35)]

mapPlot<-ggplot(data=df, aes(y=Lat, x=Long))+
  geom_raster(aes(fill=Elevation))+
  geom_point(data=sites,
             aes(y=latitude, x=longitude),
             color="white",
             size=1,
             shape=17)+
  geom_path(data=sites,
            aes(y=latitude, x=longitude),
            color="red")+
  scale_fill_gradientn(
    colours=colourSet,
    na.value = "#afdce0",
    breaks=c(1,250,500,750))+
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
ggsave(file=fileName)
