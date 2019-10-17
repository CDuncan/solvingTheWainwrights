library(sp)
library(sf)
#library(rgdal)
library(tidyverse)
library(nngeo)


# Create neighbourhood zones ----
wainwrightsPoints <- st_read('raw/shortCoords.geojson') %>%
  mutate(rowno = row_number()) 

wainwrightsGeom <- st_nn(wainwrightsPoints, wainwrightsPoints, k=5) %>%
  as_tibble(.name_repair = 'minimal') %>%
  t() %>%
  as_tibble() %>%
  mutate(origin = row_number()) %>%
  left_join(wainwrightsPoints, by=c('origin' = 'rowno')) %>%
  rename(hillO = hill, geometryO = geometry) %>%
  left_join(wainwrightsPoints, by=c('V5' = 'rowno')) %>%
  select(hill = hillO, geometryO, geometryD = geometry) %>%
  mutate(dist = st_distance(geometryO, geometryD, by_element = TRUE)) %>%
  select(hill, geometryO, dist) %>%
  mutate(dist = dist*1.5) %>%
  mutate(geometryB = st_buffer(geometryO, dist)) %>%
  select(-c(dist,geometryO)) %>% 
  st_as_sf()

hillLookup <- wainwrightsPoints %>%
  st_drop_geometry()

wainwrightsPoints <- wainwrightsPoints %>%
  select(-rowno) %>%
  rename(geometryO = geometry)


# Determine the occupants of each neighbourhood zone ----
neighbourPairs <-
  st_contains(wainwrightsGeom,wainwrightsPoints) %>%
  as_tibble(.name_repair = 'minimal') %>%
  left_join(hillLookup, by=c('row.id'='rowno')) %>%
  rename(start = hill) %>%
  left_join(hillLookup, by=c('col.id'='rowno')) %>%
  select(start, end = hill) %>%
  filter(start != end) %>%
  mutate(start = as.character(start)) %>%
  group_by(start) %>%
  mutate(end =  paste0(end, collapse = "&")) %>% 
  distinct() %>%
  rename(A = start, B = end) %>%
  write_csv('out/neighbourPairs.csv')
