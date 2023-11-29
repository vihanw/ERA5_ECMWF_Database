#!/bin/bash
#SBATCH --job-name=combine_nc
#SBATCH --mem=30gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=24:00:00

module load nco
module load netcdf

file_dir='/scratch1/wee055/ffipm/'

# Get dates
month=$(date -d "$D" '+%m')
year=$(date -d "$D" '+%Y')
year_past=$((year-2))
sub=03
month_recent=$((10#$month-10#$sub))
month_recent=$(printf "%02d" ${month_recent})
# Required climate variables
climate_var=('tasmax' 'tasmin' 'mean_precip' 'mean_pev' 'soil_tmax' 'soil_tmin')
climate_var_fname=("era5_2m_temperature_daily_maximum_" "era5_2m_temperature_daily_minimum_" "era5_total_precipitation_daily_mean_" "era5_potential_evaporation_daily_mean_" "era5_soil_temperature_level_1_daily_maximum_" "era5_soil_temperature_level_1_daily_minimum_")

# First convert the time dimension to a record dimension
for var in ${climate_var_fname[@]}
do
 extension="*.nc"
# files=($(find ${file_dir} -name ${var}${extension}|sort -g))
 files=($(find ${file_dir} -name ${var}${extension} -not -name $'*combined.nc'|sort -g))
 files_to_combine=()
 for i in $(seq 1 22)
 do
  infile=${files[${#files[@]}-$i]}
  ncks --mk_rec_dmn time $infile -O -o $infile
#  echo $infile
  files_to_combine+=($infile)
 done  
 
 combined_file=${file_dir}${var}${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
 ncrcat -O ${files_to_combine[@]} $combined_file 
 echo ${files_to_combine[@]}

 echo 'Saved '$combined_file
done 

tasmax_file=${file_dir}$'era5_2m_temperature_daily_maximum_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
tasmin_file=${file_dir}$'era5_2m_temperature_daily_minimum_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
mean_precip_file=${file_dir}$'era5_total_precipitation_daily_mean_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
mean_pev_file=${file_dir}$'era5_potential_evaporation_daily_mean_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
soil_tmax_file=${file_dir}$'era5_soil_temperature_level_1_daily_maximum_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'
soil_tmin_file=${file_dir}$'era5_soil_temperature_level_1_daily_minimum_'${year_past}'_'${month}'_'${year}'_'${month_recent}'_combined.nc'

ncap2 -O -s 'tas=tas-273.15f' $tasmax_file $tasmax_file
ncatted -a units,tas,o,c,celsius $tasmax_file
echo 'Updated units '$tasmax_file

ncap2 -O -s 'tas=tas-273.15f' $tasmin_file $tasmin_file
ncatted -a units,tas,o,c,celsius $tasmin_file
echo 'Updated units '$tasmin_file

ncap2 -O -s 'tprate=tprate*1000f*60f*60f*24f' $mean_precip_file $mean_precip_file
ncatted -a units,tprate,o,c,mm $mean_precip_file
echo 'Updated units '$mean_precip_file

ncap2 -O -s 'pev=pev*1000f' $mean_pev_file $mean_pev_file
ncatted -a units,pev,o,c,mm $mean_pev_file
echo 'Updated units '$mean_pev_file

ncap2 -O -s 'stl1=stl1-273.15f' $soil_tmax_file $soil_tmax_file
ncatted -a units,stl1,o,c,celsius $soil_tmax_file
echo 'Updated units '$soil_tmax_file

ncap2 -O -s 'stl1=stl1-273.15f' $soil_tmin_file $soil_tmin_file
ncatted -a units,stl1,o,c,celsius $soil_tmin_file
echo 'Updated units '$soil_tmin_file
