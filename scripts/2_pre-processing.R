

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

# Drought hazard assessment - Avaliacao dos riscos de seca


## Step 4. Preparate R Code

# Data path: Enter the path to a folder where you have enough free space to store your 
  # MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/test/"
dir()
# outDir <- file.path("R_output")               # Create an output directory if it doesn't exist
# suppressWarnings(dir.create(outDir))                 

# TIMESAT path: Enter the path to your TIMESAT 3.3 installation including the subfolder
  # /compiled/Win64.

TSpath <-"C:/timesat33/compiled/Win64"

# Download list path: Enter the path to your appEEARS download-list (including “.txt”!).
  # If you downloaded the data from appEEARS beforehand, enter the path to the data 
  # folder here and comment out the lines for the data download (all downloaded data 
  # needs to be in one folder).

downloadList <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/ChapadadasMesasNationalPark-download-list.txt"


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

## Step 4.1 Download Data (Script 1_download_MOD13Q1.R)

## Step 4.2 

########################





###########

# library(raster)
# 
# img <- raster::raster("C:/Users/user/Downloads/MOD13Q1_CMNP_2000-2022/MOD13Q1.006__250m_16_days_NDVI_doy2000049_aid0001.tif")
# 
# plot(img)


