# Timesat - Phenological Cycle Analysis (DEVELOPING)
Obtaining, processing and analysis of the NDVI derived from MODIS sensor for obtaining phenological metrics of vegetation (beginning, peak and end of vegetation growth cycle, its duration and maximal productivity of the phenological cycle) of the different phytophysiognomies of the biome Cerrado (Chapada das Mesas National Park - CMNP). Processing in TIMESAT software and package rTIMESAT.

## To follow the tutorial in detail at: 
  - http://rstudio-pubs-static.s3.amazonaws.com/452032_a5df2d3f782444fc830d43548a304ec5.html#A1 (Part A and B)
  - https://rpubs.com/UN-SPIDER/452043  (Part C and D)
  - https://rpubs.com/UN-SPIDER/VCI

### Step 1: Install TIMESAT 
  - http://web.nateko.lu.se/timesat/timesat.asp

### Step 2: Download MODIS data (with a temporal resolution of 16 days)
  - Login appEARS (https://lpdaacsvc.cr.usgs.gov/appeears/);
  - Download Area Sample
  - Download MODIS data (MOD13Q1-006)
  
### Step 2.1: Download MODIS data (with a temporal resolution of 7 days)
  - https://ivfl-info.boku.ac.at/
 
### Step 3: Conclude request and download data file
  - Click on the Explore tab in appEARS, then on the download button of your request;
  - Select 'All' and 'save the download list'.
 
 ### Step 4: Preparate R Code
  - Scrip 1: Download Normalized Difference Vegetation Index MOD13Q1;
  - Scrip 2: Pre-processing;
 
 ### Step 5: Generating the VCI
  - Scrip 2-1: Processing VCI;
 
 ### Step 6: Prepare TIMESAT
  - Scrip 3: Timesat prepare;
  - This step we generation the files: files NDVI-MODIS in ".envi" or ".img" or ".bqs", all can be read in software TIMESAT.
  
 ### Step 7: Run data in TIMESAT
  - 
  
 
