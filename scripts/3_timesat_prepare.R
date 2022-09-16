
#### Setp 6. Prepare TIMESAT

# TIMESAT helps extracting seasonal parameters such as Start of Season (SoS), Peak of 
  # Season (PoS) and End of Season (EoS).
# The processing in TIMESAT is controlled by a number of settings. 


# list and remove objects from workspace
ls()
rm(list = ls())

#### Load packages using the function library when required.

library(rgdal)             # Functions for spatial data input/output
library(sp)                # classes and methods for spatial data types
library(raster)            # Classes and methods for raster data
library(rasterVis)         # Advanced plotting functions for raster objects 
library(ggplot2)           # Functions for graphing and mapping
library(RColorBrewer)      # Creates nice color schemes
library(stringr)
library(rts)

# Data path: Enter the path to a folder where you have enough free space to store your 
# MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/"
pathData <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_MODIS"
dataPath2 <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/MOD13Q1_CMNP_2000-2022/MOD13Q1.006_2000046_to_2022243"

dir(pathData )

# TIMESAT path: Enter the path to your TIMESAT 3.3 installation including the subfolder
# /compiled/Win64.

TSpath <-"C:/timesat33/compiled/Win64"

#Enter the hemisphere of your study area: 1 = north; 0 = south. For South Africa set hemisphere = 0.
hemisphere <- 0

# Extract all Days of Year (DOY) and YEARs from the filenames. MODIS vegetation 
# data consists of 16-day composites. The filename contains the year and Julian
# day of acquisition

rasterData <- list.files(path=dataPath2, pattern='.tif$', recursive=F, ignore.case=T,
                         full.names=T)
NDVIrasterData <- rasterData[grepl('NDVI',basename(rasterData))]
DOYs <- unique(substr(basename(NDVIrasterData),39,41))
YEARs <- unique(substr(basename(NDVIrasterData),35,38))
length(YEARs)

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
  #writeRaster(tc, filename=paste0(dataPath,'/timesatPREP/',flname), format="IDRISI", overwrite=T)
  writeRaster(tc, filename=paste0(dataPath,'/timesatPREP/',flname), format="HFA", datatype='INT2S', overwrite=T)
  
  #(Progress report)
  print(paste0("Preparing data for TIMESAT... ", i , "/" , length(allNDVITIF)))
}




# List TIMESAT compatible files (binary files) and create a TIMESAT image list (.txt)
# with these files.
#List new, TIMESAT-compatible files
allNDVITS <- list.files(paste0(dataPath,"/timesatPREP/"), full.names=T, pattern=".rst$",recursive=F)
allNDVITS <- list.files(paste0(dataPath,"/timesatPREP/"), full.names=T, pattern=".img$",recursive=F)

#Create TIMESAT image-list
imglist <- c(length(allNDVITS),allNDVITS)
fileCr<-file( paste0(dataPath,'/forTIMESAT/TIMESATlist.txt'))
#fileCr<-read.table('C:/Users/user/Documents/GitHub/timesat_cmnp/data/forTIMESAT/TIMESATlist.txt')
writeLines(imglist,fileCr)
close(fileCr)


# Create TIMESAT setting file (.set)
#Recreate TIMESAT settings-file convention - line by line
setlines <- c()
#1: Headerline
setlines <- c(setlines, "Version: 3.3 ")
#2: Jobname
setlines <- c(setlines, "RCMDPract         %Job_name (no blanks) ")
setlines <- c(setlines, "1               %Image /series mode (1/0) ")
setlines <- c(setlines, "0               %Trend (1/0) ")
setlines <- c(setlines, "0               %Use mask data (1/0) ")
#6: Link to Filelist
setlines <- c(setlines, paste0(dataPath,"/forTIMESAT/TIMESATlist.txt         %Data file list/name "))
setlines <- c(setlines, paste0("dummy         %Mask file list/name "))
setlines <- c(setlines, paste0("3               %Image file type "))
setlines <- c(setlines, paste0("0               %Byte order (1/0) "))
#7: File dimensions
setlines <- c(setlines, paste0(nrow(raster(allNDVITS[1])), " ", ncol(raster(allNDVITS[1])) ,"         %File dimension (nrow ncol) "))
#Processing extent (=whole image)
setlines <- c(setlines, paste0("1 ", nrow(raster(allNDVITS[1])), " 1 ", ncol(raster(allNDVITS[1])) ,"   %Processing window (start row stop row start col stop col) "))
#Number of years and images per year

#Correcting the number of seasons, as seasons start in July of one and end in June of the next year in the southern hemisphere
if (hemisphere == 0){
  ycorr <- 1
}else{
  ycorr <- 0
}

setlines <- c(setlines, paste0(length(YEARs)-ycorr," 23            %No. years and no. points per year "))
#Valid value-range (0 to 1 for NDVI)
setlines <- c(setlines, paste0("0 1         %Valid data range (lower upper) "))
#More settings... (mostly not relevant for this practice but needed for the TIMESAT settings-file)
setlines <- c(setlines, paste0("-1e+06 1e+06 1         %Mask range 1 and weight "))
setlines <- c(setlines, paste0("-1e+06 1e+06 1         %Mask range 2 and weight "))
setlines <- c(setlines, paste0("-1e+06 1e+06 1         %Mask range 3 and weight "))
setlines <- c(setlines, paste0("0               %Amplitude cutoff value "))
setlines <- c(setlines, paste0("0               %Print functions and weights (1/0) "))
setlines <- c(setlines, paste0("1 1 0           %Output files (1/0 1/0 1/0) "))
setlines <- c(setlines, paste0("0               %Use land cover (1/0) "))
setlines <- c(setlines, paste0("   %Name of landcover file "))
setlines <- c(setlines, paste0("0               %Spike method "))
setlines <- c(setlines, paste0("2               %Spike value "))
setlines <- c(setlines, paste0("0               %Spatial half dimension "))
setlines <- c(setlines, paste0("1               %No. of landcover classes "))
setlines <- c(setlines, paste0("************ "))
setlines <- c(setlines, paste0("1               %Land cover code for class  1 "))
setlines <- c(setlines, paste0("1               %Season parameter "))
setlines <- c(setlines, paste0("1               %No. of envelope iterations (1-3) "))
setlines <- c(setlines, paste0("2               %Adaptation strength (1-10) "))
setlines <- c(setlines, paste0("0 -99999            %Force minimum (1/0) and value "))
setlines <- c(setlines, paste0("2               %Fitting method (1-4) "))
setlines <- c(setlines, paste0("1               %Weight update method "))
setlines <- c(setlines, paste0("4               %Window size for Sav-Gol. "))
setlines <- c(setlines, paste0("1               %Spatio-temporal smoothing factor. "))
setlines <- c(setlines, paste0("2               %Spatio-temporal adaptation factor. "))
setlines <- c(setlines, paste0("1               %Season start method "))
#Thresholds for season start/stop. Using standard-values.
TSthr <- 0.5
setlines <- c(setlines, paste0(TSthr, " ", TSthr,"         %Season start / stop values "))

#Writing TIMESAT settingsfile
fileCr<-file( paste0(dataPath,'/forTIMESAT/TIMESAT_input.set'))
writeLines(setlines,fileCr)
close(fileCr)

#Part I finished
if (length(allNDVITS) > 0){
  print("DONE - Please proceed in TIMESAT. Do NOT close this R-Session")
}

