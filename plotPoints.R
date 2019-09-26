library(tidyverse)
library(TSP)
library(geosphere)



coords <- coordsFull %>%
  dplyr::select(longitude,latitude)

distMatrix <- as.data.frame(coords) %>%
  distm(., ., distGeo)


tsp <- TSP(distMatrix)

methods <- c(
  "nearest_insertion",
  "farthest_insertion",
  "cheapest_insertion",
  "arbitrary_insertion",
  "nn",
  "repetitive_nn",
  "two_opt"
)

tours <- methods %>% 
  map(function(method) {solve_TSP(tsp, method)})

tour <- solve_TSP(tsp)
#
# Order of locations in tour.
#
tour_order <- as.integer(tour) %>%
  as_tibble() %>%
  mutate(order = row_number())


coordsFinal <- coordsFull %>%
  dplyr::select(longitude,latitude,metres)

sites <- coordsFinal %>%
  mutate(startOrder = row_number()) %>%
  left_join(tour_order,c("startOrder"="value")) %>%
  arrange(tour_order) %>%
  dplyr::select(longitude,latitude) %>%
  mutate(longitude=round(longitude*1e3,0),
         latitude=round(latitude*1e3,0))
