library(sf)
library(tidyverse)

nodePositions <- st_read('raw/shortCoords.geojson')

edgeList <- 
  nodePositions %>% 
  st_drop_geometry %>%
  mutate(id = 1) %>%
  merge(.,., by = 'id', suffixes = c('1','2'), all.x=TRUE) %>%
  select(A = hill1, B = hill2)

edgeList <- edgeList %>%
  left_join(nodePositions, by = c("A"="hill")) %>% rename(nodeA = geometry) %>%
  left_join(nodePositions, by = c("B"="hill")) %>% rename(nodeB = geometry) %>%
  mutate(crowDistance = st_distance(nodeA, nodeB, by_element = TRUE)) %>%
  select(-c(nodeA,nodeB)) %>%
  mutate(crowDistance = signif(crowDistance, 2)) %>%
  write_csv('out/crowFlies.csv')