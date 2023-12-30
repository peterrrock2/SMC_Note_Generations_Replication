#!/bin/bash

# DON'T FORGET TO CHANGE THE MEMORY!!!
shapefile_dir="examples/"
shapefile_name="50x50_grid"
pop_col="TOTPOP"

# CHANGE THIS TOL FOR STATE VS FED
pop_tol=0.01
# CHANGE THIS TOO!!!
n_dists=50
sims_list=(20)


# CHANGE THESE FOR DIFF RUNS
output_dir="examples/outputs/${shapefile_name}"
log_dir="examples/logs/${shapefile_name}"


mkdir -p "${output_dir}"
mkdir -p "${log_dir}"


rng_seeds=()
IFS=' ' read -r -a rng_seeds < "./short_rng_seeds.txt"
echo -e "Rng seeds:\n${rng_seeds[@]}"

for n_sims in "${sims_list[@]}"; do
    for rng_seed in "${rng_seeds[@]}"; do
        /usr/bin/time -v Rscript smc_cli.R \
            --shapefile "${shapefile_dir}${shapefile_name}" \
            --pop_tol $pop_tol \
            --pop_col "${pop_col}" \
            --n_dists $n_dists \
            --n_sims $n_sims \
            --rng_seed $rng_seed \
            --output_file "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.csv" \
            > "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.jsonl" \
            2> "${log_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.log" 

    done
done


