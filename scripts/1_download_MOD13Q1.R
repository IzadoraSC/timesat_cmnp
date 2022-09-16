

#### Load packages using the function library when required.
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
# library(rasterVis)         # Advanced plotting functions for raster objects 
# library(ggplot2)           # Functions for graphing and mapping
# library(RColorBrewer)      # Creates nice color schemes


# Drought hazard assessment


## Step 4. Preparate R Code

# Data path: Enter the path to a folder where you have enough free space to store your 
  # MODIS data and the resulting products. 

dataPath <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/MOD13Q1_CMNP_2000-2022/"
dir()
# outDir <- file.path("R_output")               # Create an output directory if it doesn't exist
# suppressWarnings(dir.create(outDir))                 

# TIMESAT path: Enter the path to your TIMESAT 3.3 installation including the subfolder
  # /compiled/Win64.

TSpath <-"C:/timesat33/compiled/Win64"

# Download list path: Enter the path to your appEEARS download-list (including “.txt”!).
  # If you downloaded the data from appEEARS beforehand, enter the path to the data 
  # folder here and comment out the lines for the data download (all downloaded data 
  # needs to be in one folder). (this part of the download was done differently)

downloadList <- "C:/Users/user/Documents/GitHub/timesat_cmnp/data/ChapadadasMesasNationalPark-download-list.txt"


# Analysis period: Define the period of analysis with a vector of two components. 
  # The first is the starting year and the second the final year. If you want to process
  # all available years just comment the line with a #. In this example all data is used,
  # thus the line is commented.

#AnalysisPeriod <- c(2000, 2022)

## Step 4.1 Download Data

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
  # https://lpdaac.usgs.gov/resources/e-learning/getting-started-appeears-api-r-area-request/
  # https://lpdaac.usgs.gov/documents/626/AppEEARS_API_Area.html


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


#### This API call will list all of the requests associated with your user account, 
  # automatically sorted by date descending with the most recent requests listed first.
token <- paste("Bearer", fromJSON(token_response)$token)     # Save login token to a variable


params <- list(limit = 2, pretty = TRUE)                            # Set up query parameters
# Request the task status of last 2 requests from task URL
response_req <- GET(paste0(API_URL,"task"), query = params, add_headers(Authorization = token))
response_content <- content(response_req)                           # Retrieve content of the request
status_response <- toJSON(response_content, auto_unbox = TRUE)      # Convert the content to JSON object
remove(response_req, response_content)                              # Remove the variables that are not needed anymore     
prettify(status_response)                                           # Print the prettified response

#############


#### This API call lists all of the files contained in the bundle which are available 
  # for download.

token <- paste("Bearer", fromJSON(token_response)$token) # Save login token to a variable
task_id <- "559b7267-3cab-4e8e-a9d0-aa909565a41a"
response <- GET(paste("https://appeears.earthdatacloud.nasa.gov/api/bundle/", task_id, sep = ""), add_headers(Authorization = token))
bundle_response <- prettify(toJSON(content(response), auto_unbox = TRUE))
bundle_response

########

### Download files.Each file in a bundle can be downloaded. Just as the task has a task_id to 
  # identify it, each file in the bundle will also have a unique file_id which should be used 
  # for any operation on that specific file.

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


