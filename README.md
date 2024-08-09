# Replication Repository for SMC Note

This repository is intended to serve as documentation of the processes and code used
in the numerical computations for the paper 
[Repetition effects in a Sequential Monte Carlo sampler](https://mggg.org/SMC-repetition).

In order to obtain the statistics within this paper, some light modifications to the base 
code made by the [ALARM](https://github.com/alarm-redist/redist) lab were necessary.

For the convenience of the reader, here is a quick synopsis of the changes that were made
(the numbers $n$ and $m$ respectively refer to the number of districts and the number of 
simulations throughout):

- An $n\times m$ Armadillo matrix called `probs_mat` was added to keep track of the probability
  of selecting a particular plan at a given generation of the SMC process. These correspond
  to the sampling probabilities for the partial plans found in b.1.i of Algorithm 2 of the 
  paper *Sequential Monte Carlo for Sampling Balanced and Compact Redistricting Plans* 
  found at [https://arxiv.org/abs/2008.06131](https://arxiv.org/abs/2008.06131). The version
  used was from the 14 Feb 2023 revision.

- Another $n\times m$ Armadillo matrix called `b2_mat` was added to keep track of the 
  individual plan weights at each generation. These values correspond to the term 
  given in b.2 of Algorithm 2 of the above paper as well.

- An $n\times m$ Armadillo matrix called `progenitor_mat` was added to keep track of the 
  generational information of the plans. This was done by storing at each step the index 
  of the parent plan from which the new district was to be split. So if the (1-indexed)
  row $5$ column $3$ contains the value $7$, then this indicates that the the plan 
  corresponding to position $(5,3)$, which contains $5$ districts, obtained its $5$-th
  district by splitting off a district chunk form the remaining portion of the partial 
  plan corresponding to position $(4,7)$.

The full log of the changes can be found in the following link: 

Full Changelog: [Original_Code..Modified_Code](https://github.com/mggg/redist-fork/compare/original_code...mggg:redist-fork:probs_and_generations_v1)

## Included Files

Here are some brief descriptions of the files and folders contained within this project:

- `rng_seeds.txt` A list of all the random seeds that were used for sampling SMC runs. There
  are 1000 seeds in total, and this list is included since different hardware may produce 
  different random seeds if one were to just use the 

  - `short_rng_seeds.txt` A small list of rng seeds used for generating the examples.

- `slurm_scripts/` A directory containing some examples of the slurm scripts that were used to 
  generate the desired data. Slurm scripts only work on cluster computers with a Slurm resource 
  manager, so they are generally useless without access to such a cluster, but these are included 
  in the interest of transparency
  
  - `submit_jobs.sh` The script that was used to submit jobs to the cluster. This was often 
    run as a sentinel process using the command 
    ```
    sbatch --time=7-00:00:00 --mem=1G --cpus-per-task=1 submit_jobs.sh
    ```
    As a note, many of the jobs used in the paper take a significant amount of time to execute.
    In particular, PA with 203 districts took roughly 1 day to run for each instance on the 
    hardware that we used.

  - `run_tasks.sh` The script that was used to set the resources and output files for each 
    sbatch job that was submitted to the cluster.

- `runner.sh` A bash script file that may be used to run replication work if one desires. This 
  script should work on all unix-based systems, and mimics much of the behaviour of the Slurm 
  scripts, with the obvious exception that this implementation does not allow for the simutaneous
  execution of many jobs which is possible in a cluster environment. The equivalent runner for 
  Windows machines is `wrunner.ps1`.

- `ca_runner.sh` A bash script file that is tailored to work with the RDS format of the file 
  `CA_cd_2020_map.rds` containing an `smc_map` object for CA at the tract level. This file was
  obtained from the Harvard dataverse at 
  [https://dataverse.harvard.edu/file.xhtml?fileId=6391062&version=14.0](https://dataverse.harvard.edu/file.xhtml?fileId=6391062&version=14.0)
  The equivalent runner for Windows machines is `wca_runner.ps1`.

- `smc_cli.R` A command-line interface built in R that allows for the usage of scripts to run 
  several samples of SMC without opening RStudio. The default settings for this CLI should be 
  reflective of the default settings found in the [reference material for `redist`](https://alarm-redist.org/redist/reference/index.html)


- `table_and_figure_scripts/` This folder contains the scripts used to generate the tables and 
  figures for the paper 
  [Repetition effects in a Sequential Monte Carlo sampler](https://mggg.org/SMC-repetition).
  The number of each of subdirectories should correspond to the number of the table or figure in 
  the paper. Also included are the generated CSV or PNG files for each of these scripts.
  - `table2/` Contains the scripts used to generate the table 2 of the paper. In particular,
    the script `table_2_repetition_info.py` is used to collect information on the number times
    a top-level ancestors appears in the final ensemble of plans. The script `table_2_data_aggregator.py`
    then collects statistics on these values. 
  - `figure5/` Contains the script `figure_5_hist_maker.py` which is used to collect the `b1_probs` 
    for each district for each iteration of the SMC process and then make a histogram of the
    distribution of these values compared to the uniform distribution.
  - `table3/` Contains the script `table_3_megaparent_info.py` which is used to collect the mega
    parents for each shapefile for each threshold value (the $F(D,\varphi)$ values in the paper).
  - `figure6/` Contains the script `make_generational_descendency.py` is used to track the the
    maximum number of plans in the final ensemble of which are a direct descendant of a plan
    in the given generation.

## Output Formats

Each call of the `runner.sh` script will produce three output files. 

- The `*.log` file was used to help track error and meta information on the run and is useful 
  in long runs since it allows the user to check on the progress of the run.

- The `*.csv` file contains all of the essential information needed for the data processing 
  present within the paper. The columns of each of the csv outputs are
  ```
  "","draw","district","total_pop","b1_probs","b2_wgt","parent"
  ```
  with the blank column being an indexing column.

- The `*.jsonl` file contains most of the information present within the csv, and it also 
  contains metadata from the start of the run as well as the summary from the end of the run.
  This file can be useful in event that a particular run stalls or quits early since it still
  allows for the extraction of data from the part of the run that did complete.


## Running the Replication Natively

The replication of this data assumes that the end user has [RStudio](https://cran.rstudio.com/) 
installed on their system. 

### Linux/MacOS

To prepare the system for replication, most developers should be able to 
simply run the script `setup.sh` from the terminal. However, there are a couple of 
small errors that can still appear if the system has not seen much programming use. 
Here are some tips for getting things working in the event that you experince any issues:

*Linux Common Problem Fixes*

Many of the R libraries that are used within `redist` require extra packages to be installed 
on the system. In the case of a Debian system, it would be prudent to try to run the following 
commands before trying to run `./setup.sh`

```shell
sudo apt-get update
sudo apt-get install time r-base libudunits2-dev gdal-bin libgdal-dev build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev
```

*MacOS Common Problem Fixes*

Installation of the necessary packages tends to go much smoother on MacOS, however, the linker sometimes has 
some trouble locating the `gfortran` package which is usually installed when `brew install gcc` is invoked
from the command line. The easiest way to fix this is to just edit the `Makevars` file directly. The standard 
`Makevars` file (found in `redist/src/Makevars`) is as follows:

```
CXX_STD = CXX17
PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) -DARMA_64BIT_WORD=1 -g0
PKG_LIBS = `$(R_HOME)/bin/Rscript -e "Rcpp:::LdFlags()"` `"$(R_HOME)/bin/Rscript" -e "RcppThread::LdFlags()"` $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS) $(SHLIB_OPENMP_CXXFLAGS)
```

To add the explicit link to the file, we need to find the location of the static library file. This can be done 
with the following command:

```shell
user@Users-Macbook gfortran -print-file-name=libgfortran.a

/opt/homebrew/Cellar/gcc/13.2.0/lib/gcc/current/
```

Then the updated file should look like:

```
CXX_STD = CXX17
PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) -DARMA_64BIT_WORD=1 -g0
PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) `$(R_HOME)/bin/Rscript -e "Rcpp:::LdFlags()"` `"$(R_HOME)/bin/Rscript" -e "RcppThread::LdFlags()"` $(LAPACK_LIBS) $(BLAS_LIBS) -L/opt/homebrew/Cellar/gcc/13.2.0/lib/gcc/current/ -lgfortran $(FLIBS)

```

### Windows

To prepare the system for replication, simply run the script `win_setup.bat` using PowerShell. 
The runners for replication are written in a powershell script and can be called using the 
standard `./wrunner.ps1`. As a note, installing everything in Windows can be a bit tricky,
and does require that the Visual Studio developer suite for C++, RStudio, and RTools are all 
installed on the system. Also, the Rscript executable should be added to the user's path.
This is generally found in a folder like `C:\Program Files\R\R-4.x.x\bin\R.exe`

In the course of running the replication, if you see a error saying something to the effect of 
the locale being incorrect, this likely means that your terminal environment and R environment 
are not in sync. Fixing this can be a bit troublesome, so it is best to just try to run the 
desired script from within the RStudio console.

### Using the CLI

The file `smc_cli.R` contains the main CLI for the running scripts. The flags 
for this cli correspond to the parameters for the functions `redist_map` and 
`redist_smc` from the `redist` package.

**SMC Map Parameters:**

- `--rds_map`: Specifies the RDS file name containing an `smc_map` object. When this 
  flag is used, other map-related flags are disregarded. The default value is `NULL`.

- `--shapefile`: Indicates the name of the shapefile to be used. 

- `--pop_tol`: Sets the population tolerance. This value should lie within the range 
  $[0,1]$. The default is set to `0.01`.

- `--pop_col`: Denotes the column name in the shapefile that represents the population. 

- `--n_dists`: Specifies the number of districts for redistricting. Default is set to `2`.

- `--pop_bounds`: Sets the population bounds, formatted as (lower, target, upper). If 
  not specified, it defaults to `NULL`.

**SMC Simulation Parameters:**

- `--n_sims`: Defines the number of simulations to be performed. The default is `1000`.

- `--compactness`: Sets the compactness measure for the districting plans. The default 
  value is `1.0`.

- `--resample`: This flag, when included, enables resampling during the simulations.

- `--adapt_k_thresh`: Determines the threshold for the heuristic selection of the value 
  `k_i` in each splitting iteration. The default is `0.985`.

- `--seq_alpha`: Controls the adjustment of weights at each resampling step. The default 
  setting is `0.5`.

- `--pop_temper`: Adjusts the strength of automatic population tempering. It is set to 
  `0.0` by default.

- `--final_infl`: This parameter acts as a multiplier for the population constraint, with 
  a default setting of `1`.

- `--est_label_mult`: Sets the multiplier for the number of importance samples. The 
  default is `1.0`.

- `--verbose`: Include this flag to enable detailed output during simulation.

- `--silent`: Suppresses all output when included, ensuring a quiet operation during 
  simulation.

- `--dont_adjust_labels`: Disables the sequential label adjuster when included.

**Additional Flags for Data Processing and Reproducibility:**

- `--rng_seed`: Sets the random number generator seed for the simulation. The default is 
  `42`.

- `--tally_cols`: Specifies the columns to be tallied. By default, this is set to 
  `DO_NOT_TALLY`.

- `--output_file`: Determines the name of the output file. The default name provided is 
  `test_output.csv`.

### Example Command

To run a simulation with the CLI, you might use a command structured as follows:

```shell
Rscript smc_cli.R \
--shapefile "my_shapefile" \
--pop_tol 0.05 \
--pop_col "population" \
--n_dists 4 \
--n_sims 20 \
--pop_temper 0.001 \
--output_file "my_output.csv" \
> "my_output.jsonl" \
2> "my_logs.log"
```
 
Of course, practical examples of how the CLI is used are available in the runner
files.