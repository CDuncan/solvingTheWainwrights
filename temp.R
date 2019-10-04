SDNY <- elevationRaster$landCover  %>%
  projectRaster(crs = "+init=epsg:4326",method = "ngb") %>%
  rasterToPoints() %>%
  as_tibble() %>%
  rename(
    Longitude = x,
    Latitude  = y,
    LandCover = landCover) %>%
  mutate(
    LandCover = as_factor(LandCover),
    LandCover = fct_inseq(LandCover)  )

# Plotting ----


mapPlot<-ggplot(data=SDNY, aes(y=Latitude, x=Longitude))+
  geom_raster(aes(fill=LandCover))+
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
        plot.margin=grid::unit(c(0,0,0,0), "mm"))

fileName = paste0("landCover",".png")
ggsave(file=fileName)
