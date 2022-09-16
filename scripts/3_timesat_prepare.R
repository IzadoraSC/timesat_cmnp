
#### Setp 6. Prepare TIMESAT

# TIMESAT helps extracting seasonal parameters such as Start of Season (SoS), Peak of 
  # Season (PoS) and End of Season (EoS).
# The processing in TIMESAT is controlled by a number of settings. 

#### Load packages using the function library when required.

library(rgdal)             # Functions for spatial data input/output
library(sp)                # classes and methods for spatial data types
library(raster)            # Classes and methods for raster data
library(rasterVis)         # Advanced plotting functions for raster objects 
library(ggplot2)           # Functions for graphing and mapping
library(RColorBrewer)      # Creates nice color schemes
library(stringr)


# Data path: Enter the path to a folder where you have enough free space to store your 
# MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/"
pathData <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_MODIS"

dir()

# TIMESAT path: Enter the path to your TIMESAT 3.3 installation including the subfolder
# /compiled/Win64.

TSpath <-"C:/timesat33/compiled/Win64"

# Create output folders for TIMESAT. First, the output folder for the TIMSAT preparation (timesatPREP) 
# for the setting file and second, a folder in which the TIMESAT outputs can be written (forTIMESAT).
#Creating output folders
if (!file.exists(paste0(dataPath,'/timesatPREP')))
  dir.create(paste0(dataPath,'/timesatPREP'))
if (!file.exists(paste0(dataPath,'/forTIMESAT')))
  dir.create(paste0(dataPath,'/forTIMESAT'))
if (!file.exists(paste0(dataPath,'/timesat')))
  dir.create(paste0(dataPath,'/timesat'))

# List all EVI tiffs and change their file format to binary for TIMESAT. TIMESAT can only read binary data,
# thus the tiffs need to be changed.

#Creating output folders
allNDVITIF <- list.files(paste0(dataPath,"/NDVI_MODIS/"), full.names=T, pattern=".tif$",recursive=F)
#Change file-format to binary for TIMESAT
for(i in 1:length(allNDVITIF)){
  tc <- raster(allNDVITIF[i])
  #NAs can cause trouble with TIMESAT. Replacing with -999
  tc[is.na(tc)] <- -999
  #switch filename-convention for correct sorting
  flname <- paste0(substr(basename(allNDVITIF[i]),5,8),"_",substr(basename(allNDVITIF[i]),1,3),"_NDVI-TS")
  writeRaster(tc, filename=paste0(dataPath,'/timesatPREP/',flname), format="IDRISI", overwrite=T)
  #(Progress report)
  print(paste0("Preparing data for TIMESAT... ", i , "/" , length(allNDVITIF)))
}

