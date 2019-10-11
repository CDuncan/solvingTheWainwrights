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
          georef = file.path(getwd(), 'terrainTestingArea.tif'),
          flags = c('t', 'c'))


# Import start and end
execGRASS('v.in.ogr',
          input = file.path(getwd(), 'start.geojson'),
          output = "vStart",
          flags  = 'overwrite')

execGRASS('v.in.ogr',
          input = file.path(getwd(), 'end.geojson'),
          output = "vEnd",
          flags  = 'overwrite')

# Import elevation map
execGRASS('r.in.gdal',
          input  = file.path(getwd(), 'terrainTestingArea.tif'),
          output = 'terrainTestingArea',
          flags  = 'overwrite')

execGRASS('g.region', raster = 'terrainTestingArea')
gmeta()

execGRASS('r.slope.aspect',
          elevation = 'terrainTestingArea',
          slope = 'slopeMap',
          flags  = 'overwrite')


# Calculate Tobler Layer
execGRASS('r.mapcalc',
          expression = "tobler1 = tan( slopeMap )", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler2 = tobler1 + 0.05", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler1 = abs(tobler2)", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler2 = -3.5*tobler1", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler1 = exp(tobler2)", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler2 = 6000*tobler1", flags = "overwrite")
execGRASS('r.mapcalc',
          expression = "tobler = 5/tobler2", flags = "overwrite")
#plot(readRAST("tobler"))





execGRASS('r.cost',
          input = 'tobler',
          output = 'costMap',
          start_points = "vStart",
          stop_points =  "vEnd",
          flags  = 'overwrite')


# Export maps
execGRASS('r.out.gdal',
          input = 'tobler',
          output = 'toblerOut.tif',
          format = 'GTiff',
          flags  = 'overwrite')

execGRASS('r.out.gdal',
          input = 'slopeMap',
          output = 'slopeMap.tif',
          format = 'GTiff',
          flags  = 'overwrite')

execGRASS('r.out.gdal',
          input = 'costMap',
          output = 'costMap.tif',
          format = 'GTiff',
          flags  = 'overwrite')




