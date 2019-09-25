
dat<-df

## rename columns
colnames(dat)[c(1, 2)] <- c('Easting', 'Northing')

## libraries
require(rgdal) # for spTransform
require(stringr)

### shortcuts
ukgrid <- "+init=epsg:27700"
latlong <- "+init=epsg:4326"

### Create coordinates variable
coords <- cbind(Easting = as.numeric(as.character(dat$Easting)),
                Northing = as.numeric(as.character(dat$Northing)))

### Create the SpatialPointsDataFrame
dat_SP <- SpatialPointsDataFrame(coords,
                                 data = dat,
                                 proj4string = CRS("+init=epsg:27700"))

### Convert
dat_SP_LL <- spTransform(dat_SP, CRS(latlong))

## replace Lat, Long
dat_SP_LL@data$Long <- coordinates(dat_SP_LL)[, 1]
dat_SP_LL@data$Lat <- coordinates(dat_SP_LL)[, 2]

df <- dat_SP_LL@data %>% 
  dplyr::select(Lat,Long,Elevation) 