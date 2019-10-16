library(sp)
library(sf)
library(rgdal)
library(tidyverse)
#library(ggspatial)
#library(raster)


# Create neighbourhood zones ----
wainwrightsPoints <- st_read('wainwrightCoords.geojson') %>%
  mutate(rowno = row_number()) %>%
  select(-c(latitude, longitude)) 

hillLookup <- wainwrightsPoints %>%
  rename(hill = hillnumber) %>%
  st_drop_geometry()
  

wainwrightsGeom <- st_nn(wainwrightsPoints, wainwrightsPoints, k=5) %>%
  as_tibble(.name_repair = 'minimal') %>%
  t() %>%
  as_tibble() %>%
  mutate(origin = row_number()) %>%
  left_join(wainwrightsPoints, by=c('origin' = 'rowno')) %>%
  rename(hill = hillnumber, geometryO = geometry) %>%
  left_join(wainwrightsPoints, by=c('V5' = 'rowno')) %>%
  select(hill, geometryO, geometryD = geometry) %>%
  mutate(dist = st_distance(geometryO, geometryD, by_element = TRUE)) %>%
  select(hill, geometryO, dist) %>%
  mutate(dist = dist*1.5) %>%
  mutate(geometryB = st_buffer(geometryO, dist)) %>%
  select(-c(dist,geometryO)) %>% 
  st_as_sf()

wainwrightsPoints <- wainwrightsPoints %>%
  select(-rowno) %>%
  rename(hill = hillnumber, geometryO = geometry)


# Determine the occupants of each neighbourhood zone ----
x <- st_contains(wainwrightsGeom,wainwrightsPoints) %>%
  as_tibble(.name_repair = 'minimal') %>%
  left_join(hillLookup, by=c("row.id"="rowno")) %>%
  rename(start = hill) %>%
  left_join(hillLookup, by=c("col.id"="rowno")) %>%
  select(start, end = hill) %>%
  filter(start != end) %>%
  group_by(start) %>%
  mutate(end =  paste0(end, collapse = ",")) %>%
  distinct()
