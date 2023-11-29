The collection of scripts download Historical ERA5 data, ECMWF 10-day forecasts to create a continuous dataset for 2 years into the past

## Background and Requirements

- Data sources:
1. ERA5 historical data - https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview
https://confluence.ecmwf.int/pages/viewpage.action?pageId=228867588 
2. ECMWF 10-day forecasts -
https://www.ecmwf.int/en/forecasts/datasets/set-i

- The era5 data is accessed via the Copernicus Data Server (CDS) using a python script, please follow the instructions [here](https://cds.climate.copernicus.eu/api-how-to) to setup access

- The forecast data is accessed via the ECMWF API, please follow the instructions [here](https://www.ecmwf.int/en/forecasts/access-forecasts/ecmwf-web-api) to create an account and get access to the ECMWF API. Also check how to setup the ECMWF API key under your home directory.

- The scripts are run on the Pearcey HPC 

- To run, use the command `sbatch --array=0-5 era5_download.sh`

## Climate Variables
1. 2m temperature - daily_maximum
2. 2m temperature - daily_minimum
3. Precipitation - daily_total
4. Daily potential evaporation
5. Soil temperature: 0 --7cm - daily_minimum
6. Soil temperature: 0--7cm - daily_maximum

## Steps 
The output continuous dataset will combine the historical and forecast data in the following way
![plot](testing_notebook/output_dataset_timeline.png)

### 1. Download ERA5 dataset dating back 2 years  
- ERA5 historical reanalysis data: 2 years in the past to 3 month before current month
- Summary of era5 data downloaded from era5_download.sh and era5_download.py

|     Variable       |     dimensions                           |     Name of   variable:      Long name                                                                |     Raw data unit    |     Unit to be converted   to         |
|--------------------|------------------------------------------|-------------------------------------------------------------------------------------------------------|----------------------|---------------------------------------|
|     tasmax         |     time=xx     lat=1801     lon=3601    |     Tas (time,lat,lon)                                                                                |     K                |     C     = -273.15                   |
|     tasmin         |     time=xx     lat=1801     lon=3601    |     Tas (time,lat,lon)                                                                                |     K                |     C     = -273.15                   |
|     Mean_precip    |     time=xx     lat=1801     lon=3601    |     Tprate (time,lat,lon)     Total   precipitation rate                                              |     m s-1            |     mm d-1     = (1000)x(60*60*24)    |
|     Mean_pev       |     time=xx     lat=1801     lon=3601    |     pev (time,lat,lon)     thickness of   the liquid water equivalent potential evaporation amount    |     m                |     mm     = 1000                     |
|     soil_tmax      |     time=xx     lat=1801     lon=3601    |     stl1 (time,lat,lon)     top soil   layer temperature                                              |     K                |     C     = -273.15                   |
|     soil_tmin      |     time=xx     lat=1801     lon=3601    |     stl1 (time,lat,lon)     top soil   layer temperature                                              |     K                |     C     = -273.15                   |


### 2. Download the ECMWF 10-day forecasts dating back 3 months and 10 days into the future
- ECMWF 10-day forecasts: 3 months in the past until most recent predictions (pseudo-observations)
- ECMWF 10-day forecasts: 10-days into the future
- Data are available at 6-hour intervals
- Add up 4 x 6-hour data for each day, converting 10-day forecast into daily summaries

### 3. Continuously update the datasets updating can happen once per week. In conclusion, each week, we should provide 2 yrs + 10 day forecast into the future
