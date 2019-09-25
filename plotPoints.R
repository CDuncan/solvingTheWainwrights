library(tidyverse)
library(TSP)
library(geosphere)


coordsFull <-
  read_csv("coordsOfExtendedWainwrights.csv") %>%
  filter(WO==0) 

coords <- coordsFull %>%
  dplyr::select(longitude,latitude)

coDF <- as.data.frame(coords)
distMatrix <- distm(coDF, coDF, distGeo)


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

tours <- methods %>% map(function(method) {
  solve_TSP(tsp, method)
})

tour <- solve_TSP(tsp)
#
# Order of locations in tour.
#
tour_order <- as.integer(tour)
ordering <- as_tibble(tour_order) %>%
  mutate(order = row_number())


coordsFinal <- coordsFull %>%
  dplyr::select(longitude,latitude,metres)

sites <- coordsFinal %>%
  mutate(startOrder = row_number()) %>%
  left_join(ordering,c("startOrder"="value")) %>%
  arrange(order) %>%
  dplyr::select(longitude,latitude) %>%
  mutate(longitude=round(longitude*1e3,0),
         latitude=round(latitude*1e3,0))
