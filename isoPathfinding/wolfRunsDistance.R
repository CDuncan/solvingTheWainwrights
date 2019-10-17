library(rgdal)
library(rgrass7)
library(tidyverse)
library(fs)

# Detect mapped hills
subFolder <- 'out/pathCosts'
generatedFiles <-  subFolder %>% 
  dir_ls(regexp = "\\.csv$") %>%
  as_tibble() %>%
  mutate(
    value = str_replace(value,'out/pathCosts/hill_',''),
    value = str_replace(value,'.csv',''))
                             


# Remove mapped hills from list of hills to map
neighbourPairs <- read_csv('out/neighbourPairs.csv',col_types = cols(A = col_character())) %>%
  filter(!(A %in% generatedFiles$value)) %>%
  mutate(B = str_replace_all(B,'&',','))


# Initialise the raster
use_sp()
initGRASS(gisBase  = "C:/Program Files/GRASS GIS 7.6",
          gisDbase = getwd(),
          location = 'grassdata',
          mapset   = "PERMANENT", 
          override = TRUE)

execGRASS("g.proj", 
          georef = file.path(getwd(), 'out/isoCost.tif'),
          flags = c('t', 'c'))

# Import cost surface
execGRASS('r.in.gdal',
          input  = file.path(getwd(), 'out/isoCost.tif'),
          output = 'tobler',
          flags  = c('overwrite','quiet'))


# Select calculation region
execGRASS('g.region', 
          raster = 'tobler')

# Import all peaks
execGRASS('v.in.ogr',
          input = file.path(getwd(), 'raw/shortCoords.geojson'),
          output = "allCoords",
          flags  = 'overwrite')

for (i in 1:length(neighbourPairs$A)) {

  # Isolate origin and destination points
  hillNumber = neighbourPairs$A[i]
  neighbourList = neighbourPairs$B[i]
  
  # Select origin point
  execGRASS('v.extract',
            input = 'allCoords',
            output = "vOrigin",
            where = paste0('hill = ',hillNumber,sep=""),
            Sys_show.output.on.console=FALSE,
            flags  = c('overwrite','quiet'))
  
  # Select destination points
  execGRASS('v.extract',
            input = 'allCoords',
            output = "vDestination",
            where = paste0('hill IN (',neighbourList,')',sep=""),
            Sys_show.output.on.console=FALSE,
            flags  = c('overwrite','quiet'))
  
  # Calculate accumulated cost map
  execGRASS('r.cost',
            input = 'tobler',
            output = 'costMap',
            start_points = "vOrigin",
            stop_points =  "vDestination",
            memory = 4000,
            flags  = c('overwrite','quiet','k'))
  

  execGRASS('v.what.rast',
            map = 'vDestination',
            raster = 'costMap',
            column = 'cost',
            flags = 'quiet')
  
  # Add an origin label column
  execGRASS('v.db.addcolumn',
            map = 'vDestination',
            columns = 'origin',
            flags = 'quiet')
  
  # Set the origin
  execGRASS('v.db.update',
            map = 'vDestination',
            column = 'origin',
            value = hillNumber,
            flags = 'quiet')
  
  # Extract vector data to .csv format
  execGRASS('v.db.select',
            map = 'vDestination',
            columns = 'origin,hill,cost',
            separator = 'comma',
            file = paste0('out/pathCosts/hill_',hillNumber,'.csv',sep=""),
            flags = 'overwrite')
  
  outputLine <- paste0(i,'/',length(neighbourPairs$A),'  ')
  cat('\r',outputLine)
}


generatedFiles <-  subFolder %>% 
  dir_ls(regexp = "\\.csv$") %>%
  map_dfr(read_csv, .id = "source", col_types = cols()) %>%
  select(-source) %>%
  rename(A = origin, B = hill, wolfDistance = cost) %>%
  write_csv('out/wolfRuns.csv')