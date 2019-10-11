library(sp)
library(sf)
library(raster)
library(rgdal)
library(rgrass7)
library(tidyverse)
library(ggspatial)

use_sp()

initGRASS(gisBase  = "C:/OSGeo4W64/apps/grass/grass76",
          gisDbase = getwd(),
          location = 'grassdata',
          mapset   = "PERMANENT", 
          override = TRUE)

execGRASS("g.proj", 
          georef = file.path(getwd(), 'terrainTestingArea.tif'),
          flags = c('t', 'c'))

execGRASS('r.in.gdal',
          input  = file.path(getwd(), 'terrainTestingArea.tif'),
          output = 'terrainTestingArea',
          flags  = 'overwrite')

execGRASS('g.region', raster = 'terrainTestingArea')
gmeta()

execGRASS('r.slope.aspect',
          elevation = 'terrainTestingArea',
          slope = 'slopeMap')



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
plot(readRAST("tobler"))




execGRASS('r.mapcalc',
          expression = toblerFunction,
          flags = "overwrite")


execGRASS('r.cost',
          input = 'tobler',
          output = 'costMap')


slopeMap <- readRAST('slopeMap')
terrainTest <- readRAST('tobler') %>% 
  st_as_sf() 




library(Rsagacmd)
saga <- saga_gis("C:/OSGeo4W64/apps/saga-ltr/saga_cmd.exe")
dem <- raster('terrainTestingArea.tif')


slope <- dem
dem %>%
  saga$ta_morphometry$slope_aspect_curvature(SLOPE = slope, UNIT_SLOPE = 1)

saga$io_gdal$export_geotiff(GRIDS = "slope", FILE ="slope.tif")


library(RSAGA)
env <- rsaga.env()








