#!/bin/bash
#SBATCH --job-name=era5_download
#SBATCH --mem=16gb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=05-00:00:00
#SBATCH --mail-user=wee055@csiro.au
#SBATCH --partition=io

module load miniconda3/4.9.2
conda init bash
conda activate /home/wee055/python/conda_py3.8_env

climate_variables=( 'tasmax' 'tasmin' 'mean_precip' 'mean_pev' 'soil_tmax' 'soil_tmin')

python era5_download_daily.py ${climate_variables[$((  $SLURM_ARRAY_TASK_ID))]}

