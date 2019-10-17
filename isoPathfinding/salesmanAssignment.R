wolfDist <-  
  read_csv('out/wolfRuns.csv', col_types = cols(
    A = col_character(),
    B = col_character()))

crowDist <-  
  read_csv('out/crowFlies.csv', col_types = cols(
    A = col_character(),
    B = col_character())) %>%
  left_join(wolfDist, by = c('A' = 'A', 'B' = 'B')) %>% rename(forwardWolf = wolfDistance) %>%
  left_join(wolfDist, by = c('A' = 'B', 'B' = 'A')) %>% rename(reverseWolf = wolfDistance) %>%
  mutate(isoCost = case_when(
    !is.na(forwardWolf) ~ forwardWolf,
    !is.na(reverseWolf) ~ reverseWolf,
    TRUE ~ crowDistance*1000)) %>%
  select(A,B,isoCost)
  


nameVals <- sort(unique(crowDist$A))
myMat <- matrix(0, length(nameVals), length(nameVals), dimnames = list(nameVals, nameVals))
myMat <- as.data.frame(myMat)

for (i in 1:length(crowDist$A)) {
  myMat[crowDist$A[i],crowDist$B[i]] <- crowDist$isoCost[i]
}


library(TSP)

myMat <- as.matrix(myMat)
tsp <- TSP(myMat)

tour <- 
  tsp %>%
  solve_TSP() %>%
  as.integer() %>%
  as_tibble() %>%
  rename(node = value) %>%
  mutate(order = row_number()) 

listOrder <- crowDist %>%
  select(A) %>%
  distinct() %>%
  mutate(node = row_number())

wainwrightsPoints <- st_read('raw/shortCoords.geojson') %>%
  mutate(hill = as.character(hill)) 

tourOut <- tour %>%
  left_join(listOrder) %>%
  mutate(B = lead(A)) %>%
  mutate(B = c(B[-n()], A[1])) %>%
  select(-node) %>%
  left_join(wainwrightsPoints, by = c("A"="hill")) %>%
  rename(geom1 = geometry) %>%
  left_join(wainwrightsPoints, by = c("B"="hill")) %>%
  rename(geom2 = geometry)

  x<-c(tourOut$geom1)
  x<-x %>% st_combine() %>% st_cast(to="LINESTRING")
  plot(x)
  