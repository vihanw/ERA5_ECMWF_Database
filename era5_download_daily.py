#! /usr/bin/python

import cdsapi
import requests
from datetime import datetime
from dateutil.relativedelta import relativedelta
import sys
import os

# Set directory to store the data 
file_dir = sys.argv[1:][1]

# Climate variable required passsed from era5_download.sh
climate_var = sys.argv[1:][0]

# Function to match above defimned climate variables to their var, stat pair
def mapClimateVarStat(climate_var):
    if (climate_var == 'tasmax'):
        return '2m_temperature', 'daily_maximum'
    elif (climate_var == 'tasmin'):
        return '2m_temperature', 'daily_minimum'
    elif (climate_var == 'mean_precip'):
        return 'total_precipitation', 'daily_mean' 
    elif (climate_var == 'mean_pev'):
        return 'potential_evaporation', 'daily_mean'
#         return 'evaporation_from_bare_soil', 'daily_mean'
    elif (climate_var == 'soil_tmax'):
        return 'soil_temperature_level_1', 'daily_maximum'
    elif (climate_var == 'soil_tmin'):
        return 'soil_temperature_level_1', 'daily_minimum'
        
## Function to download era5 data at a monthly scale
# Inputs - month (1-12), 
#          year (2020,2021, etc), 
#          var (2m_temperature, large_scale_precipitation, soil_temperature_level_1 etc.),
#          stat (daily_maximum, daily_minimum, daily_mean etc.)
     
def downloadEra5Data(month,year,var,stat,file_name):
    c = cdsapi.Client(timeout=300)
    
    result = c.service(
        "tool.toolbox.orchestrator.workflow",
        params={
             "realm": "c3s",
             "project": "app-c3s-daily-era5-statistics",
             "version": "master",
             "kwargs": {
                 "dataset": "reanalysis-era5-single-levels",
                 "product_type": "reanalysis",
                 "variable": var,
                 "statistic": stat,
                 "year": year,
                 "month": "{:02d}".format(month),
                 "time_zone": "UTC+00:0",
                 "frequency": "1-hourly",
                 "grid": "0.1/0.1",
#                "area":{"lat": [10, 60], "lon": [65, 140]}
 
                 },
        "workflow_name": "application"
        })
    
    # Save the file
    location=result[0]['location']
    res = requests.get(location, stream = True)
    print("Writing data to " + file_name)
    with open(file_name,'wb') as fh:
        for r in res.iter_content(chunk_size = 1024):
            fh.write(r)
    fh.close()

if __name__ == "__main__":
    date_today = datetime.now().strftime('%Y-%m-%d')
    year_today = date_today[0:4]
    month_today = date_today[5:7]

    date_2yrs_ago = datetime.now() - relativedelta(years=2)
    date_2yrs_ago = date_2yrs_ago.strftime('%Y-%m-%d')
    year_2yrs_ago = date_2yrs_ago[0:4]
    month_2yrs_ago = date_2yrs_ago[5:7]
    
    initial_month = month_2yrs_ago
    month_count_2yrs = 24-3
    
    var, stat = mapClimateVarStat(climate_var)
    month = int(initial_month)
    month_count = 0
    
    
    for year in range(int(year_2yrs_ago), int(year_today)+1):
        for m in range(month_count_2yrs):

            if (month_count <= month_count_2yrs):
                if (month > 12):
                    month = 1
                    break
                else:
                    ## Pass the function here 
                    ##
                    file_name = file_dir + "era5_" + str(var) + "_" + str(stat) + "_" + str(year) + "_" + str("{:02d}".format(month)) + ".nc"
                    if (os.path.exists(file_name)):
                        print("File already downloaded: "+str(file_name))
                    else:
                        print("Downloading: "+str(file_name))
                        for attempt in range(10):
                            try:
                                downloadEra5Data(month,year,var,stat,file_name)
                            except:
                                print("Attempt " + str(attempt) + " failed, trying again")
                            else:
                                break
                        else:
                            print("All attempts failed at downloading: " + str(file_name)+" Continuing with other files")
                            continue

                    month = month + 1
                    month_count = month_count+1
            else:
                break
