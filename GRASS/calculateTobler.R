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
          georef = file.path(getwd(), 'terr5.tif'),
          flags = c('t', 'c'))

# Import elevation map
execGRASS('r.in.gdal',
          input  = file.path(getwd(), 'terr5.tif'),
          output = 'terrainTestingArea',
          flags  = 'overwrite')
execGRASS('g.region', 
          raster = 'terrainTestingArea')
execGRASS('r.slope.aspect',
          elevation = 'terrainTestingArea',
          slope = 'slopeMap',
          flags  = 'overwrite')


# Calculate Tobler Layer
execGRASS('r.mapcalc',
          expression = "tobler2 = tan( slopeMap )", flags = "overwrite")
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


execGRASS('r.out.gdal',
          input = 'tobler',
          output = 'OUT/toblerOut.tif',
          format = 'GTiff',
          flags  = 'overwrite')
