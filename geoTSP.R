library(tidyverse)
library(TSP)
library(geosphere)

coordsFull <-
  read_csv("coordsOfExtendedWainwrights.csv") %>%
  filter(WO==0) 

coords <- coordsFull %>%
  dplyr::select(longitude,latitude)

distMatrix <- as.data.frame(coords) %>%
  distm(., ., distGeo)
tsp <- TSP(distMatrix)

# Solve tour and give order of locations in tour.
tour <- 
  tsp %>%
  solve_TSP() %>%
  as.integer() %>%
  as_tibble() %>%
  rename(node = value) %>%
  mutate(order = row_number())


sites <- coordsFull %>%
  mutate(node = row_number()) %>%
  left_join(tour,by="node") %>%
  arrange(order) %>%
  dplyr::select(longitude,latitude) %>%
  mutate(longitude=round(longitude*1e3,0),
         latitude=round(latitude*1e3,0))


if (FALSE){
  methods <- c(
    "nearest_insertion",
    "farthest_insertion",
    "cheapest_insertion",
    "arbitrary_insertion",
    "nn",
    "repetitive_nn",
    "two_opt")
  
  tours <- methods %>% 
    map(function(method) {solve_TSP(tsp, method)})
}