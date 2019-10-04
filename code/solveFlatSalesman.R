
wainwrightsCoords <-
  read_csv("rawData/listData/coordsOfExtendedWainwrights.csv") %>%
  filter(WO==0)

travellingSalesman <-
  wainwrightsCoords %>%
  dplyr::select(longitude,latitude) %>%
  as_tibble() %>%
  distm(., ., distGeo) %>%
  TSP()

tour <-
  travellingSalesman %>%
  solve_TSP() %>%
  as.integer() %>%
  as_tibble() %>%
  rename(node = value) %>%
  mutate(order = row_number())

sites <-
  wainwrightsCoords %>%
  mutate(node = row_number()) %>%
  left_join(tour,by="node") %>%
  arrange(order) %>%
  dplyr::select(longitude,latitude)
