#######################
####### Data NDVI with cloud mask - R script

# Carregando pacotes

library(raster)
library(rgdal)
library(sp)

### Step 5: Generating the VCI
# 5.1 Scrip 2-1: Processing VCI

#enter link to the folder where you have stored the MODIS EVI data

pathData <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/data_NDVI"
dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data"

dlist <- dir(pathData,pattern="DOY")

# enter link to the folder where you have stored the MODIS Pixel Reliability data

pathData_c <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/Data_Pixel_Reliability"  
dlist_c <- dir(pathData_c,pattern="DOY")


#insert link to the shapefile with the country borders

border <- readOGR(dsn = path.expand("C:/Users/user/Documents/GitHub/timesat_cmnp/data/shp"),
                  layer = 'ret_env_modis')

plot(border)
str(border)

#enter the links to the folder where you want to store the resulting .jpg-images and .tif-files.

if (!file.exists(paste0(dataPath,'/NDVI_jpg')))
  dir.create(paste0(dataPath,'/NDVI_jpg'))

#data NDVI whit cloudmask
path_jpg <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_jpg"  
path_tif <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_jpg"
# 
# #data NDVI whitout cloudmask
# path_jpg <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_MODIS"  
# path_tif <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/NDVI_MODIS"

# Creating a progress bar in the Console, wich ends at the end of the loop. The progress bar
# looks like this:

pb <- txtProgressBar (min=0, max=length(dlist), style=1)
setTxtProgressBar (pb, 0)


#### https://rpubs.com/UN-SPIDER/VCI
#Creating a progress bar in the Console, wich ends at the end of the loop. The progress bar looks
# like this:
#Main code for processing the EVI data, masking out clouds, calculating the VCI and writing the results

for (i in 1:length(dlist)) {                   # start of the outer for-loop
  fold <- paste(pathData,dlist[i],sep="/")         # the respective DOY folder of the data_NDVI folder
  fls <- dir(fold,pattern=".tif")              # all files that are available in the respective NDVI DOY folder
  flsp <-paste(fold,fls,sep="/")               # all files that are available in the respective NDVI DOY folder with complete path name
  
  ndvistack <- stack(flsp)                      # creates a layer stack of all files within the NDVI DOY folder
  ndviresize<- crop(ndvistack,border)            # resizes the NDVI layer stack to the rectangular extent of the border shapefile
  ndvimask<-mask(ndviresize,border)              # masks the EVI layer stack using the border shapefile
  ndvi<-ndvimask*0.0001                          # rescaling of MODIS NDVI data
  ndvi[ndvi==-0.3]<-NA                           # NDVI fill value(-0,3) in NA 
  ndvi[ndvi<(0)]<-NA                             # as we are only interested in vegetation valid NDVI range is 0 to 1 and all NDVI values smaller than 0 set to NA
  
  fold_c <- paste(pathData_c,dlist_c[i],sep="/")   # the respective DOY folder of the Data_Pixel_Reliability folder
  fls_c <- dir(fold_c,pattern=".tif")          # all files that are available in the respective Pixel Reliability DOY folder
  flsp_c <-paste(fold_c,fls_c,sep="/")         # all files that are available in the respective Pixel Reliability DOY folder with complete path name
  
  cloudstack <- stack(flsp_c)                  # creates a layer stack of all files within the Pixel Relaibility DOY folder
  cloudresize<- crop(cloudstack,border)        # resizes the Pixel Reliability layer stack to the rectangular extent of the border shapefile
  cloudmask<-mask(cloudresize,border)          # masks the Pixel Reliability layer stack using the border shapefile
  cloudmask[cloudmask==(3)]<-NA                # Pixel Reliability rank 3 pixels (cloudy) set to NA
  cloudmask[cloudmask==(2)]<-NA                # Pixel Reliability rank 2 pixels (snow&ice) set to NA
  cloudmask[cloudmask==(0)]<-1                 # Pixel Reliability rank 0 pixels (good quality) set to 1
  cloudmask[cloudmask>(3)]<-NA                 # as valid Pixel Reliability range is -1 to 3, all Pixel Reliability values >3 set to NA
  # (as -1 rank pixels show value 255)
  
  ndvi_c=ndvi*cloudmask                          # multiplying the EVI layer stack by the Pixel Reliability layer stack
  # to get one single layer stack with applied cloud mask
  
  # # extracting max and min value for each pixel
  # ndvimax <- stackApply (ndvi_c, rep (1, nlayers (ndvi)), max, na.rm=T) #calculating the max value for the layer stack for each individual pixel
  # ndvimin <- stackApply (ndvi_c, rep (1, nlayers (ndvi)), min, na.rm=T) #calculating the min value for the layer stack for each individual pixel
  # 
  # 
  # if na.rm is TRUE NA values are ignored, otherwise an NA value in any of the arguments will cause a value of NA to be returned,
  # https://stat.ethz.ch/R-manual/R-devel/library/base/html/Extremes.html
  
  # VCI_all <- ((ndvi_c-ndvimin)/(ndvimax-ndvimin))*100 #calculating VCI
  
  
  # define breaks and color scheme
  
  my_palette <- colorRampPalette(c('#8B0000', '#FF4500', '#FFFF00', '#9ACD32', '#008000'))
  
  fold_jpg <- paste(path_jpg)                                         # the respective folder where you want to store the resulting .jpg-images.
  fold_tif <- paste(path_tif)                                         # the respective folder where you want to store the resulting .tif-files.
  
  
  for (k in 1:nlayers(ndvi_c)) {     # start of the inner for-loop
    
    
    year <- substr(fls[k],5,8)        # extracting the fifth to eigths letter of the filename, which is the year (cf. data preparation above)
    doy <- substr(fls[k],1,3)         # extracting the first to third letter of the filename, which is the DOY (cf. data preparation above)
    
    
    writeRaster(ndvi_c[[k]], filename=paste(fold,"/",doy,"_",year,sep=""), format="ENVI", datatype='FLT4S', overwrite=TRUE)
    # in case you would like to have Envi files (Attention: note the datatype)
    
    jpeg(filename=paste(fold_jpg,"/",doy,"_",year,".jpg",sep=""), quality = 100) 
    # writes the jpg maps and names the files autmatically according to the pattern DOY_YYYY
    
    
    plot(ndvi[[1]],
         zlim=c(0,1),
         col=my_palette(101),                                           # sets the colors as defined above
         main=paste("NDVI"," (no_cloudmask)"," sample ",doy," ",year,sep="")) # automizes the title of the plot.
    # ToDo: Adjust the file naming according to the data you are processing!
    # E.g. if you base your VCI on NDVI data, write (NDVI)
    
    
    dev.off()
    
    
    writeRaster(ndvi_c[[k]], filename=paste(fold_tif,"/",doy,"_",year,".tif",sep=""), format="GTiff", overwrite=TRUE)
    writes the geotiff and automizes the file naming according to the pattern DOY_YYYY
    # writeRaster(ndvi[[k]], filename=paste(fold_tif,"/",doy,"_",year,".tif",sep=""), format="GTiff", datatype='INT1S' overwrite=TRUE)
    
    
  } # end of the inner for-loop
  
  
  setTxtProgressBar (pb, i)
  
}   # end of the outer for-loop
