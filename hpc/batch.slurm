#!/bin/bash -l
#SBATCH --cluster="wice"
#SBATCH --nodes="1"
#SBATCH --job-name="low RES buildout sensetivity"
#SBATCH --mail-user="alexander.hoogsteyn@kuleuven.be"
#SBATCH --mail-type=FAIL,END,BEGIN
#SBATCH --time="8:59:00"
#SBATCH --ntasks="1"
#SBATCH --cpus-per-task=16
#SBATCH --account="lp_elect_gen_modeling"
#SBATCH --partition="batch"
#SBATCH --error="%x_%A.e"
#SBATCH --array=10-10

cd $VSC_DATA/EU-ETS-H2-support-instruments

srun $VSC_DATA/julia-1.8.5/bin/julia --threads 16 MAIN.jl --start_scen $SLURM_ARRAY_TASK_ID --stop_scen $SLURM_ARRAY_TASK_ID --start_sens 10 --stop_sens 10 > hpc/Scenario_$SLURM_ARRAY_TASK_ID.log
