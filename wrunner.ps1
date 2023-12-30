$shapefile_dir = "examples/"
$shapefile_name = "50x50_grid"
$pop_col = "TOTPOP"

# CHANGE THIS TOL FOR STATE VS FED
$pop_tol = 0.01
# CHANGE THIS TOO!!!
$n_dists = 50
$sims_list = @(20)

# CHANGE THESE FOR DIFF RUNS
$output_dir = "examples/outputs/$shapefile_name"
$log_dir = "examples/logs/$shapefile_name"

# Creating directories if they don't exist
New-Item -Path $output_dir -ItemType Directory -Force
New-Item -Path $log_dir -ItemType Directory -Force

# Reading rng_seeds from file
$rng_seeds_file = Get-Content "./short_rng_seeds.txt" -Raw
$rng_seeds = $rng_seeds_file -Split '\s+'
Write-Host "Rng seeds: $($rng_seeds -join ', ')"

foreach ($n_sims in $sims_list) {
    foreach ($rng_seed in $rng_seeds) {
        # Command and parameters
        $cmd = "Rscript"
        $args = @(
            "smc_cli.R",
            "--shapefile", "${shapefile_dir}${shapefile_name}",
            "--pop_tol", $pop_tol,
            "--pop_col", $pop_col,
            "--n_dists", $n_dists,
            "--n_sims", $n_sims,
            "--rng_seed", $rng_seed,
            "--output_file", "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.csv"
        )
        
        # Execute and redirect stderr
        $process = Start-Process -FilePath $cmd -ArgumentList $args -NoNewWindow -RedirectStandardOutput "${output_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.jsonl" -RedirectStandardError "${log_dir}/${rng_seed}_${shapefile_name}_to_${n_dists}_with_${n_sims}_sims.log" -Wait -PassThru
    }
}

