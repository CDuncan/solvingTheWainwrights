library(sp)
library(sf)
library(raster)
library(rgdal)
library(rgrass7)
library(tidyverse)
library(ggspatial)

use_sp()
initGRASS(gisBase  = "C:/Program Files/GRASS GIS 7.6",
          gisDbase = getwd(),
          location = 'grassdata',
          mapset   = "PERMANENT", 
          override = TRUE)
execGRASS("g.proj", 
          georef = file.path(getwd(), 'OUT/toblerOut.tif'),
          flags = c('t', 'c'))

execGRASS('r.in.gdal',
          input  = file.path(getwd(), 'OUT/toblerOut.tif'),
          output = 'tobler',
          flags  = 'overwrite')



# Import start and end


execGRASS('v.in.ogr',
          input = file.path(getwd(), 'shortCoords.geojson'),
          output = "allCoords",
          flags  = 'overwrite')

X = '2320'
execGRASS('v.extract',
          input = 'allCoords',
          output = "vOrigin",
          where = paste0('hill = ',X,sep=""),
          flags  = 'overwrite')

A<- x %>%
  filter(start==X) %>%
  pull(end)
execGRASS('v.extract',
          input = 'allCoords',
          output = "vDestination",
          where = paste0('hill IN (',A,')',sep=""),
          flags  = 'overwrite')



# Import elevation map
execGRASS('g.region', 
          raster = 'tobler')

execGRASS('r.cost',
          input = 'tobler',
          output = 'costMap',
          start_points = "vOrigin",
          stop_points =  "vDestination",
          flags  = c('overwrite','k'))
execGRASS('v.what.rast',
          map = 'vDestination',
          raster = 'costMap',
          column = 'cost')

execGRASS('v.out.ogr',
          input = 'vDestination',
          format = 'GeoJSON',
          output = paste0(X,'_costs.geojson'))


