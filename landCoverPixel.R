library(tidyverse)
library(rgdal)
library(raster)
library(ggplot2)
library(marmap)
library(grid)
library(sf)


landCover <- 
  readOGR("landCover/boundedPackage/boundedPackage.gpkg") %>%
  st_as_sf() %>%
  mutate(
    modal_class = as_factor(modal_class),
    modal_class = fct_inseq(modal_class))

colourList <- read_csv("landCover/colourList.csv") %>%
  pull(Hex)

sites <-
  read_csv("coordsOfExtendedWainwrights.csv") %>%
  filter(WO==0) %>%
  dplyr::select(longitude,latitude) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)



ggplot(data = landCover) +
  geom_sf(aes(fill = modal_class),lwd=0, colour = NA)+
  scale_fill_manual(values=colourList)+
  geom_sf(data=sites,
             color="black",
             size=1,
             shape=17)+
  theme_light()+  
  theme(axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16, angle=90),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "right",
        legend.key = element_blank(),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))+
  labs(fill = "Land Type") 

fileName = paste0("map/mapPlot_LC2_","191001",".png")
ggsave(file=fileName)


