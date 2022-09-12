library(rTIMESAT)
library(raster)
library(phenofit)

# Drought hazard assessment


## Step 4. Preparate R Code

# Data path: Enter the path to a folder where you have enough free space to store your 
  # MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/MOD13Q1_CMNP_2000-2022/"
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


#### Load packages using the function library when required.
library(raster)
library(curl)
library(rgdal)
library(rts)
library(stringr)
library(getPass)           # A micro-package for reading passwords
library(httr)              # To send a request to the server/receive a response from the server
library(jsonlite)          # Implements a bidirectional mapping between JSON data and the most important R data types
library(geojsonio)         # Convert data from various R classes to 'GeoJSON' 
library(geojsonR)          # Functions for processing GeoJSON objects
library(rgdal)             # Functions for spatial data input/output
library(sp)                # classes and methods for spatial data types
library(raster)            # Classes and methods for raster data
library(rasterVis)         # Advanced plotting functions for raster objects 
library(ggplot2)           # Functions for graphing and mapping
library(RColorBrewer)      # Creates nice color schemes

## Step 5. Download Data

#### Download NDVI and Pixel Reliability data which was previously ordered from 
  # appEEARS. The text file contains all ordered granules (including ‘VI quality 
  # control’ data which is automatically ordered but which is not needed). If you
  # downloaded your data from appEEARS beforehand, comment out the following eight
  # lines below using #.
### 

### But before: LOGIN

#### Create a token by calling AppEEARS API login service. Update the “USERNAME” and
  # “PASSEWORD” with yours below
# To the sucess this step consult:
  # file:///C:/Users/user/Downloads/AppEEARS_API_Area_R.html


user <- getPass(msg = "Enter NASA Earthdata Login Username: ")         # Enter NASA Earthdata Login Username
password <- getPass(msg = "Enter NASA Earthdata Login Password: ")    # Enter NASA Earthdata Login Password


secret <- jsonlite::base64_enc(paste(user, password, sep = ":"))  # Encode the string of username and password

API_URL = 'https://appeears.earthdatacloud.nasa.gov/api/'     # Set the AppEEARS API to a variable


# Insert API URL, call login service, set the component of HTTP header, and post the request to the server
response <- httr::POST(paste0(API_URL,"login"), add_headers("Authorization" = paste("Basic", gsub("\n", "", secret)),
                                                            "Content-Type" =
                                                              "application/x-www-form-urlencoded;charset=UTF-8"), 
                       body = "grant_type=client_credentials")

response_content <- content(response)                          # Retrieve the content of the request
token_response <- toJSON(response_content, auto_unbox = TRUE)  # Convert the response to the JSON object
remove(user, password, secret, response)                       # Remove the variables that are not needed anymore 
prettify(token_response)                                       # Print the prettified response


###PROVAVELMENTE ESSA PARTE NÃO FUNCIONOU
# Create a handle
# s = new_handle()
# handle_setheaders(s, 'Authorization'=paste("Bearer", fromJSON(token_response)$token))

# prods_req <- GET(paste0(API_URL, "product"))             # Request the info of all products from product service
# prods_content <- content(prods_req)                      # Retrieve the content of request 
# all_Prods <- toJSON(prods_content, auto_unbox = TRUE)    # Convert the info to JSON object
# remove(prods_req, prods_content)                         # Remove the variables that are not needed anymore

####Verificando
#DAQUI ATÉ
response <- POST(paste0(API_URL, "task"), body = task_json , encode = "json", 
                 add_headers(Authorization = token, "Content-Type" = "application/json"))

task_content <- content(response)                                     # Retrieve content of the request 
task_response <- jsonlite::toJSON(task_content, auto_unbox = TRUE)    # Convert the content to JSON and prettify it
prettify(task_response)                                               # Print the task response
#############
##Before downloading the request output, examine the files contained in the request output.

task_id <- fromJSON(task_response)[[1]]
response <- GET(paste0(API_URL, "bundle/", task_id), add_headers(Authorization = token))
bundle_response <- prettify(toJSON(content(response), auto_unbox = TRUE))


####

#AQUI

#### essa parte funcionou
token <- paste("Bearer", fromJSON(token_response)$token)     # Save login token to a variable


params <- list(limit = 2, pretty = TRUE)                            # Set up query parameters
# Request the task status of last 2 requests from task URL
response_req <- GET(paste0(API_URL,"task"), query = params, add_headers(Authorization = token))
response_content <- content(response_req)                           # Retrieve content of the request
status_response <- toJSON(response_content, auto_unbox = TRUE)      # Convert the content to JSON object
remove(response_req, response_content)                              # Remove the variables that are not needed anymore     
prettify(status_response)                                           # Print the prettified response

#############
## 
## By: https://appeears.earthdatacloud.nasa.gov/api/?language=r#download-file

#### Essa parte funcionou bem

token <- paste("Bearer", fromJSON(token_response)$token) # Save login token to a variable
task_id <- "559b7267-3cab-4e8e-a9d0-aa909565a41a"
response <- GET(paste("https://appeears.earthdatacloud.nasa.gov/api/bundle/", task_id, sep = ""), add_headers(Authorization = token))
bundle_response <- prettify(toJSON(content(response), auto_unbox = TRUE))
bundle_response

###VERIFICAR DAQUI ATÉ

# create a destination directory to store the file in
dest_dir <- 'your-destination-directory'
filepath <- paste(dest_dir, filename, sep = '/')
suppressWarnings(dir.create(dirname(filepath)))

# write the file to disk using the destination directory and file name 
response <- GET(paste("https://appeears.earthdatacloud.nasa.gov/api/bundle/", task_id, '/', file_id, sep = ""),
                write_disk(filepath, overwrite = TRUE), progress(), add_headers(Authorization = token))

# AQUI
########

### Essa parte deu certo e foi feita por ultimo
bundle <- fromJSON(bundle_response)$files
for (id in bundle$file_id){
  # retrieve the filename from the file_id
  filename <- bundle[bundle$file_id == id,]$file_name           
  # create a destination directory to store the file in
  filepath <- paste(dataPath,filename, sep = "/")
  suppressWarnings(dir.create(dirname(filepath)))
  # write the file to disk using the destination directory and file name 
  response <- GET(paste0(API_URL, "bundle/", task_id, "/", id), 
                  write_disk(filepath, overwrite = TRUE), progress(),
                  add_headers(Authorization = token))
}


########################



# library(raster)
# 
# img <- raster::raster("C:/Users/user/Downloads/MOD13Q1_CMNP_2000-2022/MOD13Q1.006__250m_16_days_NDVI_doy2000049_aid0001.tif")
# 
# plot(img)


