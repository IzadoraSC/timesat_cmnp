

#### Load packages using the function library when required.
library(rTIMESAT)
library(phenofit)
library(jsonlite)          # Implements a bidirectional mapping between JSON data and the most important R data types
library(geojsonio)         # Convert data from various R classes to 'GeoJSON' 
library(geojsonR)          # Functions for processing GeoJSON objects
library(rgdal)             # Functions for spatial data input/output
library(sp)                # classes and methods for spatial data types
library(raster)            # Classes and methods for raster data
library(rasterVis)         # Advanced plotting functions for raster objects 
library(ggplot2)           # Functions for graphing and mapping
library(RColorBrewer)      # Creates nice color schemes
library(rts)
library(stringr)
library(zoo)
library(curl)

# Drought hazard assessment - Avaliacao dos riscos de seca
  # focuses on the drought hazard assessment which uses a weighted 
  # linear combination of Normalized Difference Vegetation Index (NDVI) phenology 
  # and Vegetation condition index (VCI).
  # concentra-se na avaliação do risco de seca que utiliza uma combinação linear 
  # ponderada de fenologia do Índice de Vegetação da Diferença Normalizada (NDVI)
  # e do Índice de Vegetação Condicionada (VCI).

## Step 4. Preparate R Code

# Data path: Enter the path to a folder where you have enough free space to store your 
  # MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/MOD13Q1_CMNP_2000-2022/MOD13Q1.006_2000046_to_2022243/"

dir()

# TIMESAT path: Enter the path to your TIMESAT 3.3 installation including the subfolder
  # /compiled/Win64.

TSpath <-"C:/timesat33/compiled/Win64"

# Enter the hemisphere of your study area: 1 = north; 0 = south. For South Africa set 
  # hemisphere = 0.

hemisphere <- 0

# Quality masking: set 1 to use MODIS pixel reliability data, set 0 to not use MODIS 
  # pixel reliability data. The use of quality masking is recommended.

cloudmask <- 1

# Analysis period: Define the period of analysis with a vector of two components. 
  # The first is the starting year and the second the final year. If you want to process
  # all available years just comment the line with a #. In this example all data is used,
  # thus the line is commented.

#AnalysisPeriod <- c(2000, 2022)

##### Step 4.1 Download Data (Script 1_download_MOD13Q1.R)######

##### Step 4.2 Pre-processing####

# Create a temporary directory for intermediate calculations and setting memory limit to 
# improve the computing capacity of R.

#Creating a temp-directory, setting memory limit

dir.create(paste0(dataPath,'/temp/'))
rasterOptions(tmpdir=paste0(dataPath,'/temp/'))
rasterOptions(tolerance=1)
memory.limit(80000)

# List all downloaded tifs (NDVI and pixel reliability) in the data folder and extract 
# their basenames
rasterData <- list.files(path=dataPath, pattern='.tif$', recursive=F, ignore.case=T, 
                         full.names=T)

rasterFiles <- basename(rasterData)


# Set chunk size for processing (in pixel). Splitting the data into chunks allows
# processing of large data sets without memory problems. You can reduce these numbers 
# to 500 or 250 if you face RAM-problems.
chwidth <- 1000
chheight <- 1000


#Starting VCI processing
# List all NDVI rasters (NDVIrasterData) and their corresponding pixel reliability 
  # data (NDVIqc).
NDVIrasterData <- rasterData[grepl('NDVI',basename(rasterData))]
NDVIqc <- rasterData[grepl('pixel_reliability',basename(rasterData))]


# Load example image of downloaded rasters for chunk shapefile determination and 
# automatically adjust chunk size for small scenes (if needed).
exRST <- raster(NDVIrasterData[1])
exPR <- raster(NDVIqc[1])
plot(exPR)

initial <- raster(NDVIrasterData[1])
if (as.numeric(ncol(initial)) <= chwidth || as.numeric(nrow(initial)) <= chheight){
  chwidth <- ceiling(ncol(initial)/2)
  }

# Extract all Days of Year (DOY) and YEARs from the filenames. MODIS vegetation 
# data consists of 16-day composites. The filename contains the year and Julian
# day of acquisition
DOYs <- unique(substr(basename(NDVIrasterData),38,40))
YEARs <- unique(substr(basename(NDVIrasterData),34,37))

#VCI: chunkwise calculation
# Create output folders for masked NDVI and VCI.
if (!file.exists(paste0(dataPath,'/VCI')))
  dir.create(paste0(dataPath,'/VCI'))
if (!file.exists(paste0(dataPath,'/NDVI')))
  dir.create(paste0(dataPath,'/NDVI'))
if (!file.exists(paste0(dataPath,'/VCIjpg')))
  dir.create(paste0(dataPath,'/VCIjpg'))

# Determine data chunks and create a shapefile for each chunk (see image above).
#Determining chunks
exRST <- raster(NDVIrasterData[1])
h        <- ceiling(ncol(exRST)/ceiling(ncol(exRST) / chwidth))
v        <- ceiling(nrow(exRST)/ceiling(nrow(exRST) / chheight))
#Creating shapefile for each chunk
split      <- aggregate(exRST,fact=c(h,v))
split[]    <- 1:ncell(split)
splitshp <- rasterToPolygons(split)
names(splitshp) <- 'shapes'
notiles <- ncell(split)

# Define good values of pixel reliability data. Filter values 0 and 1 represent
# good and marginal data. Both are considered in this analysis. Cloudy pixels and
# pixels with snow or ice are removed.
goodValues <- c(0,1)

##### trabalhando a partir daqui
readr::read_file(NDVIrasterData)

# open modis bands (layers with sur_refl in the name)
all_modis <- list.files(dataPath, pattern = glob2rx("*_aid0001.tif$"),
                        full.names = TRUE)
# create spatial raster stack
all_modis_bands_pre_st <- stack(all_modis)
all_modis_bands_pre_br <- brick(all_modis_bands_pre_st)

#https://rpubs.com/UN-SPIDER/VCI_large_areas

##Mask data with pixel reliability (good values = 0, 1) and split masked data into chunks.
#Masking clouds/snows; Splitting data into chunks
for (d in 1:length(DOYs)){
  #Filtering all relevant data for this DOY
  vrasterData <- NDVIrasterData[grepl(paste0(DOYs[d],'_aid'),NDVIrasterData)]
  #..and their corresponding pixel reliability data
  vQC <- NDVIqc[grepl(paste0(DOYs[d],'_aid'),NDVIqc)]
  #Reading years of available data
  vYear <- substr(basename(vrasterData),34,37)
  for (y in 1:length(vYear)){
    viPRE <- raster(vrasterData[y])
    #Applying quality mask to each image (if masking was activated)
    if (cloudmask == 1){
      qc <- raster(vQC[y])
      viPRE <- overlay(viPRE, qc, fun = function(x, y) {
        x[!(y %in% goodValues)] <- NA
        return(x)
      })
    }

for(i in 1:ncell(split)){
  ex          <- extent(splitshp[splitshp$shapes==i,])
  exx         <- crop(viPRE,ex)
  writeRaster(exx,filename=paste0(dataPath,'/temp/',DOYs[d],'_',vYear[y],'_EVICHUNK',formatC(i, width=3, flag='0')),format='GTiff', overwrite=TRUE)
}
}
#(Progress report)
print(paste0('Data preparation (VCI) & masking (Step 2 of 6): ',round(d / length(DOYs)  * 100, digits=2),'%'))
}

########################





###########

# library(raster)
# 
# img <- raster::raster("C:/Users/user/Downloads/MOD13Q1_CMNP_2000-2022/MOD13Q1.006__250m_16_days_NDVI_doy2000049_aid0001.tif")
# 
# plot(img)


