

#### Load packages using the function library when required.

library(rgdal)             # Functions for spatial data input/output
library(sp)                # classes and methods for spatial data types
library(raster)            # Classes and methods for raster data
library(rasterVis)         # Advanced plotting functions for raster objects 
library(ggplot2)           # Functions for graphing and mapping
library(RColorBrewer)      # Creates nice color schemes
library(stringr)


# Drought hazard assessment - Avaliacao dos riscos de seca
  # focuses on the drought hazard assessment which uses a weighted 
  # linear combination of Normalized Difference Vegetation Index (NDVI) phenology 
  # and Vegetation condition index (VCI).
  # concentra-se na avaliação do risco de seca que utiliza uma combinação linear 
  # ponderada de fenologia do Índice de Vegetação da Diferença Normalizada (NDVI)
  # e do Índice de Vegetação Condicionada (VCI).

## 4.2 Scrip 2: Pre-processing;


# dir mean
dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data"

#insert link to the shapefile with the country borders

border <- readOGR(dsn = path.expand("C:/Users/user/Documents/GitHub/timesat_cmnp/data/shp"),
                  layer = 'ret_env_modis')

plot(border)
str(border)

extent(border)
extent(exNDVI)

#enter link to the folder where you have stored the MODIS EVI data

pathData <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/data_NDVI"
# mydir <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/data_NDVI/DOY_001"
dlist <- dir(pathData,pattern="DOY")

# enter link to the folder where you have stored the MODIS Pixel Reliability data

pathData_c <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/Data_Pixel_Reliability"  
dlist_c <- dir(pathData_c,pattern="DOY")


# List all NDVI rasters (NDVI) and their corresponding pixel reliability 
# data (NDVIqc).
NDVI <- list.files(path="C:/Users/user/Documents/GitHub/timesat_cmnp/data/data_NDVI/DOY_001", pattern='.tif$', recursive=F, ignore.case=T, 
                   full.names=T)
# NDVIqc <- list.files(path=pathData_c, pattern='.tif$', recursive=F, ignore.case=T, 
#                      full.names=T)
# #Showing an example of the downloaded NDVI data
exNDVI <- raster(NDVI[1])
plot(exNDVI)
myExtent <- readOGR(exNDVI, border)
myExtent <- ?spTRansform(exNDVI, CRS(proj4string(exNDVI)))

# 
# #Showing an example of the corresponding Pixel Reliability
# exNDVIqc <- raster(NDVIqc[1])
# plot(exNDVIqc)


#file.rename(list.files(), paste(as.Date(substr(list.files(),35,41),"%Y%j"),".tif", sep=""))
#file.rename(list.files(), paste(as.Date(substr(list.files(),1,13),"%Y.%m.%d"), "%Y%j"),".tif", sep=""))


## conversao de dias julianos "%Y%j" para "%Y.%m.%d" and rename

li<-as.data.frame(list.files(pattern = ".tif|.TIF"))
#li$nn<-paste0(substr(li[,1],1,34),format(as.Date(substr(li[,1],35,41), "%Y%j"),"%Y.%m.%d"),substr(li[,1],42,53))
li$nn <- paste0(gsub(li[,1],1,substr(li[,1],39,41)), "_", substr(li[,1],35,53))
for (i in 1:nrow(li)){
  is.pattern = grep(li[i,1],li)
  if (identical(is.pattern,integer(0)) == FALSE){
    sapply(li[is.pattern],FUN=function(eachPath){ 
      file.rename(from=eachPath,to= sub(pattern= li[i,1],replacement = li[i,2],eachPath))
    })
  }
}

#Conversao II
li<-as.data.frame(list.files(pattern = ".tif|.TIF"))
li$nn <- paste0(gsub(li[,1],1,substr(li[,1],1,8)), "_", substr(li[,1],20,23))

for (i in 1:nrow(li)){
  is.pattern = grep(li[i,1],li)
  if (identical(is.pattern,integer(0)) == FALSE){
    sapply(li[is.pattern],FUN=function(eachPath){ 
      file.rename(from=eachPath,to= sub(pattern= li[i,1],replacement = li[i,2],eachPath))
    })
  }
}


## Criando pasta
# Create output folders for masked NDVI and VCI.
if (!file.exists(paste0(pathData,'/DOY_001')))
  dir.create(paste0(pathData,'/DOY_001'))
if (!file.exists(paste0(pathData,'/DOY_017')))
  dir.create(paste0(pathData,'/DOY_017'))
if (!file.exists(paste0(pathData,'/DOY_033')))
  dir.create(paste0(pathData,'/DOY_033'))
if (!file.exists(paste0(pathData,'/DOY_049')))
  dir.create(paste0(pathData,'/DOY_033'))
if (!file.exists(paste0(pathData,'/DOY_049')))
  dir.create(paste0(pathData,'/DOY_049'))
if (!file.exists(paste0(pathData,'/DOY_065')))
  dir.create(paste0(pathData,'/DOY_065'))
if (!file.exists(paste0(pathData,'/DOY_081')))
  dir.create(paste0(pathData,'/DOY_081'))
if (!file.exists(paste0(pathData,'/DOY_097')))
  dir.create(paste0(pathData,'/DOY_097'))
if (!file.exists(paste0(pathData,'/DOY_113')))
  dir.create(paste0(pathData,'/DOY_113'))
if (!file.exists(paste0(pathData,'/DOY_129')))
  dir.create(paste0(pathData,'/DOY_129'))
if (!file.exists(paste0(pathData,'/DOY_145')))
  dir.create(paste0(pathData,'/DOY_145'))
if (!file.exists(paste0(pathData,'/DOY_161')))
  dir.create(paste0(pathData,'/DOY_161'))
if (!file.exists(paste0(pathData,'/DOY_177')))
  dir.create(paste0(pathData,'/DOY_177'))
if (!file.exists(paste0(pathData,'/DOY_193')))
  dir.create(paste0(pathData,'/DOY_193'))
if (!file.exists(paste0(pathData,'/DOY_209')))
  dir.create(paste0(pathData,'/DOY_209'))
if (!file.exists(paste0(pathData,'/DOY_225')))
  dir.create(paste0(pathData,'/DOY_225'))
if (!file.exists(paste0(pathData,'/DOY_241')))
  dir.create(paste0(pathData,'/DOY_241'))
if (!file.exists(paste0(pathData,'/DOY_257')))
  dir.create(paste0(pathData,'/DOY_257'))
if (!file.exists(paste0(pathData,'/DOY_273')))
  dir.create(paste0(pathData,'/DOY_273'))
if (!file.exists(paste0(pathData,'/DOY_289')))
  dir.create(paste0(pathData,'/DOY_289'))
if (!file.exists(paste0(pathData,'/DOY_305')))
  dir.create(paste0(pathData,'/DOY_305'))
if (!file.exists(paste0(pathData,'/DOY_321')))
  dir.create(paste0(pathData,'/DOY_321'))
if (!file.exists(paste0(pathData,'/DOY_337')))
  dir.create(paste0(pathData,'/DOY_337'))
if (!file.exists(paste0(pathData,'/DOY_353')))
  dir.create(paste0(pathData,'/DOY_353'))



# t4 <- "001_2001001_aid0001.tif"
# t <- "MOD13Q1.006__250m_16_days_NDVI_doy2000049_aid0001.tif"
# t <- "MOD13Q1.006__250m_16_days_pixel_reliability_doy2000081_aid0001.tif"
# str_count(t4)
# str_locate(t, 'o')

## conversao de dias julianos "%Y%j" para "%Y.%m.%d" and rename (Pixel Reliability)
setwd(pathData_c)

li<-as.data.frame(list.files(path = pathData_c, pattern = ".tif|.TIF"))
#li$nn<-paste0(substr(li[,1],1,34),format(as.Date(substr(li[,1],35,41), "%Y%j"),"%Y.%m.%d"),substr(li[,1],42,66))
li$nn <- paste0(gsub(li[,1],1,substr(li[,1],52,54)), "_", substr(li[,1],48,66))
for (i in 1:nrow(li)){
  is.pattern = grep(li[i,1],li)
  if (identical(is.pattern,integer(0)) == FALSE){
    sapply(li[is.pattern],FUN=function(eachPath){ 
      file.rename(from=eachPath,to= sub(pattern= li[i,1],replacement = li[i,2],eachPath))
    })
  }
}

#Conversao II
li<-as.data.frame(list.files(path = pathData_c, pattern = ".tif|.TIF"))
li$nn <- paste0(gsub(li[,1],1,substr(li[,1],1,8)), "_", substr(li[,1],20,23))

for (i in 1:nrow(li)){
  is.pattern = grep(li[i,1],li)
  if (identical(is.pattern,integer(0)) == FALSE){
    sapply(li[is.pattern],FUN=function(eachPath){ 
      file.rename(from=eachPath,to= sub(pattern= li[i,1],replacement = li[i,2],eachPath))
    })
  }
}








########################
#AnalysisPeriod <- c(2000, 2022)


# List all downloaded tifs (NDVI and pixel reliability) in the data folder and extract 
# their basenames
# rasterData <- list.files(path=dataPath, pattern='.tif$', recursive=F, ignore.case=T, 
#                          full.names=T)
# 
# rasterFiles <- basename(rasterData)


#Starting VCI processing
# List all NDVI rasters (NDVIrasterData) and their corresponding pixel reliability 
  # data (NDVIqc).
# NDVIrasterData <- rasterData[grepl('NDVI',basename(rasterData))]
# NDVIqc <- rasterData[grepl('pixel_reliability',basename(rasterData))]
# 
# 
# # Load example image of downloaded rasters for chunk shapefile determination and 
# # automatically adjust chunk size for small scenes (if needed).
# exRST <- raster(NDVIrasterData[1])
# exPR <- raster(NDVIqc[1])
# plot(exPR)

# Extract all Days of Year (DOY) and YEARs from the filenames. MODIS vegetation 
# data consists of 16-day composites. The filename contains the year and Julian
# day of acquisition
# DOYs <- unique(substr(basename(NDVIrasterData),38,40))
# YEARs <- unique(substr(basename(NDVIrasterData),34,37))


# open modis bands (layers with sur_refl in the name)
# all_modis <- list.files(dataPath, pattern = glob2rx("*_aid0001.tif$"),
#                         full.names = TRUE)
# # create spatial raster stack
# all_modis_bands_pre_st <- stack(all_modis)
# all_modis_bands_pre_br <- brick(all_modis_bands_pre_st)

########################

