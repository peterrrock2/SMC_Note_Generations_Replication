#!/bin/bash

# DON'T FORGET TO CHANGE THE MEMORY!!!

shapefile_name="PA"
pop_col="TOTPOP"

# CHANGE THIS TOL FOR STATE VS FED
pop_tol=0.05
# CHANGE THIS TOO!!!
n_dist=203
sims_list=(5000)

max_concurrent_jobs=200

# CHANGE THESE FOR DIFF RUNS
output_dir="PA_203_out/${shapefile_name}_203"
log_dir="PA_203_log/${shapefile_name}_203"



mkdir -p "${output_dir}"
mkdir -p "${log_dir}"


init_seed=42
RANDOM=$init_seed

rng_seeds=()
count=0
# Loop to make sure that the numbers are unique
while [ $count -lt $n_random ]; do 
    rand_num=$((RANDOM*RANDOM%100000000))
    if [[ ! " ${rng_seeds[@]} " =~ " ${rand_num} " ]]; then
        rng_seeds+=($rand_num)
        count=$((count + 1))
    fi
done

echo -e "Rng seeds:\n${rng_seeds[@]}"

for n_sims in "${sims_list[@]}"; do
    job_ids=()
    job_index=0

    for rng_seed in "${rng_seeds[@]}"; do
        # Check if we have 10 jobs running
        while [ ${#job_ids[@]} -ge $max_concurrent_jobs ]; do
            sleep 10  # Wait for 10 seconds before checking the job status again
            for job_id in "${job_ids[@]}"; do
                if squeue -j $job_id >/dev/null 2>&1; then
                    if ! squeue -j $job_id | grep -q $job_id; then
                        # Job has finished, remove it from the array
                        job_ids=(${job_ids[@]/$job_id})
                        echo "Job $job_id has finished."
                        break  # Break the inner loop
                    fi
                else
                    echo "Job $job_id might have completed, failed, or been cancelled."
                    job_ids=(${job_ids[@]/$job_id})  # Remove job ID from the array
                fi
            done
        done

        # Submit a new job
        base_log_file="${rng_seed}_${shapefile_name}_to_${n_dist}_with_${n_sims}_sims"
        job_output=$(sbatch --output="${log_dir}/${base_log_file}.log" \
                    --error="${log_dir}/${base_log_file}.log" \
                    run_task.sh "$shapefile_name" "$pop_col" "$pop_tol" "$n_sims" "$output_dir" "$log_dir" "$rng_seed" "$n_dist")
        job_id=$(echo "$job_output" | awk '{print $NF}')
        echo "Job output: $job_output"
        job_ids+=($job_id)  # Add new job ID to the array

        job_index=$((job_index + 1))
    done
    

    # Wait for all jobs to complete
    # Will have one job in the queue still since that 
    # job is used to submit things
    while [ ${#job_ids[@]} -gt 1 ]; do
        sleep 60  # Wait for 60 seconds before checking the job status again
        for job_id in "${job_ids[@]}"; do
            if squeue -j $job_id >/dev/null 2>&1; then
                if ! squeue -j $job_id | grep -q $job_id; then
                    # Job has finished, remove it from the array
                    job_ids=("${job_ids[@]/$job_id}")
                    echo "Job $job_id has finished."
                fi
            else
                echo "Job $job_id might have completed, failed, or been cancelled."
                job_ids=("${job_ids[@]/$job_id}")  # Remove job ID from the array
            fi
        done

        # Reindex the array to remove any null elements
        job_ids=("${job_ids[@]}")

        # Print remaining job IDs
        if [ ${#job_ids[@]} -gt 1 ]; then
            echo "Jobs still in queue: ${job_ids[@]}"
        fi
    done

    echo "All jobs have completed."
done