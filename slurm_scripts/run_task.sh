#!/bin/bash

#SBATCH --ntasks=1               # Number of tasks (processes)
#SBATCH --cpus-per-task=4        # Number of CPUs per task
#SBATCH --mem=4G                 # Memory limit per node
#SBATCH --time=1-06:00:00        # Limit time
#SBATCH --mail-type=ALL          # Specify mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=prock01@tufts.edu   # Where to send mail

shapefile_name=$1
pop_col=$2
pop_tol=$3
n_sims=$4
output_dir=$5
log_dir=$6
rng_seed=$7
n_dist=$8

log_file="${log_dir}/${rng_seed}_${shapefile_name}_to_${n_dist}_with_${n_sims}_sims.log"

{
    time Rscript smc_cli.R \
        --shapefile "$shapefile_name" \
        --pop_tol "$pop_tol" \
        --pop_col "$pop_col" \
        --n_dists "$n_dist" \
        --n_sims "$n_sims" \
        --rng_seed "$rng_seed" \
        --output_file "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dist}_with_${n_sims}_sims.csv"
} > "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dist}_with_${n_sims}_sims.jsonl"

# Record resource usage
base_log_file="${rng_seed}_${shapefile_name}_to_${n_dist}_with_${n_sims}_sims"
log_file="${log_dir}/${base_log_file}.log"  

sacct -j $SLURM_JOB_ID --format=JobID,JobName,Partition,State,ExitCode,Start,End,Elapsed,NCPUS,NNodes,NodeList,ReqMem,MaxRSS,AllocCPUS,Timelimit,TotalCPU >> "$log_file" 2>> "$log_file"
