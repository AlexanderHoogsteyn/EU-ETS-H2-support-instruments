#!/bin/bash -l

#SBATCH --cluster="wice"
#SBATCH --job-name="calibration"
#SBATCH --nodes="1"
#SBATCH --mail-user="alexander.hoogsteyn@kuleuven.be"
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time="49:59:00"
#SBATCH --ntasks-per-node="16"
#SBATCH --account="lp_elect_gen_modeling"
#SBATCH --partition="batch"

cd $VSC_DATA/EU-ETS-hydrogen

srun julia --threads=16  MAIN.jl --start_scen 1 --stop_scen 1 --start_sens 1 --stop_sens 1
