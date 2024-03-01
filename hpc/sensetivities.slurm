#!/bin/bash -l

#SBATCH --cluster="wice"
#SBATCH --nodes="1"
#SBATCH --job-name="sensetivities_all_scen_1"
#SBATCH --mail-user="alexander.hoogsteyn@kuleuven.be"
#SBATCH --mail-type=FAIL,END,BEGIN
#SBATCH --time="5:59:00"
#SBATCH --ntasks="1"
#SBATCH --cpus-per-task=16
#SBATCH --account="lp_elect_gen_modeling"
#SBATCH --partition="batch"
#SBATCH --error="%x_%A.e"
#SBATCH --array=1-11


cd $VSC_DATA/EU-ETS-H2-support-instruments

srun $VSC_DATA/julia-1.8.5/bin/julia --threads 16 MAIN.jl --start_scen 10 --stop_scen 10 --start_sens $SLURM_ARRAY_TASK_ID --stop_sens $SLURM_ARRAY_TASK_ID  > hpc/Sensetivity_$SLURM_ARRAY_TASK_ID.log
