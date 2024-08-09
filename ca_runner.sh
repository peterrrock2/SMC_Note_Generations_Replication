#!/bin/bash

map_dir="./data/shapefiles/"
map_name="CA_cd_2020_map"


sims_list=(20)


output_dir="examples/outputs/${map_name}"
log_dir="examples/logs/${map_name}"

mkdir -p "${output_dir}"
mkdir -p "${log_dir}"

rng_seeds=()
IFS=' ' read -r -a rng_seeds < "./short_rng_seeds.txt"
echo -e "Rng seeds:\n${rng_seeds[@]}"


for n_sims in "${sims_list[@]}"; do
    for rng_seed in "${rng_seeds[@]}"; do
        /usr/bin/time -v Rscript smc_cli.R \
        --rds_map "${map_dir}${map_name}.rds" \
        --n_sims $n_sims \
        --rng_seed $rng_seed \
        --output_file "${output_dir}/${rng_seed}_${map_name}_with_${n_sims}_sims.csv" \
        > "${output_dir}/${rng_seed}_${map_name}_with_${n_sims}_sims.jsonl" \
        2> "${log_dir}/${rng_seed}_${map_name}_with_${n_sims}_sims.log"

        echo "Done with ${rng_seed}_${map_name}_with_${n_sims}_sims"
    done
done

