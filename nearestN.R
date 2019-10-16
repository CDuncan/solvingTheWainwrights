#library(sp)
library(sf)
#library(raster)
library(rgdal)
library(tidyverse)
#library(ggspatial)


# Create neighbourhood zones ----
wainwrights <- st_read("wainwrightCoords.geojson") %>%
  select(-c(latitude,longitude)) %>%
  mutate(rowno = row_number())

wainwrights2 <- st_nn(wainwrights,wainwrights,k=5) %>%
  as_tibble(.name_repair = "minimal") %>%
  t() %>%
  as_tibble() %>%
  select(destination = V5) %>%
  mutate(origin = row_number()) 

wainwrights2 <- wainwrights2 %>%
  mutate(geometryO = wainwrights$geometry[wainwrights$rowno==wainwrights2$origin]) %>%
  left_join(wainwrights,by=c("destination"="rowno")) %>%
  select(origin,destination,geometryO,geometryD=geometry) %>%
  mutate(dist = st_distance(geometryO,geometryD, by_element = TRUE)) %>%
  select(geometryO,dist) %>%
  mutate(dist = dist*2)
  
wainwrights <- wainwrights %>%
  select(-rowno)

# Determine the occupants of each neighbourhood zone ----


st_is_within_distance()


