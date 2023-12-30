library(argparser)
library(sf)
library(dplyr)
library(ggplot2)
library(devtools)
load_all("redist")
library(jsonlite)


p <- arg_parser("This is a basic CLI app for running the redist package")

# TAGS FOR THE REDIST_MAP CALL
p <- add_argument(p,
                  "--rds_map",
                  help="Enter the name of the rds file containing the map",
                  default=NULL,
                  type="character")
p <- add_argument(p, 
                  "--shapefile", 
                  help="Enter the name of the shapefile (must be in current directory and cannot include \"./\")",
                  type="character")
p <- add_argument(p, 
                  "--pop_tol", 
                  help="Enter the allowable population deviance [between 0 and 1]",
                  default=0.01, 
                  type="double")
p <- add_argument(p, 
                  "--pop_col", 
                  help="Enter the name of the population column within the shapefile",
                  default="TOTPOP", 
                  type="character")
p <- add_argument(p, 
                  "--n_dists", 
                  help="Enter the number of districts for the redistricting.", 
                  default=2, 
                  type="integer")
p <- add_argument(p,
                  "--pop_bounds",
                  help="Enter the population bounds with formatting (lower, target, upper)",
                  default=NULL, 
                  type="integer",
                  nargs=3)

# TAGS FOR THE REDIST_SMC CALL
p <- add_argument(p, 
                  "--n_sims", 
                  help="Enter the number of simulations to draw from",
                  default=1000, 
                  type="integer")
p <- add_argument(p,
                  "--compactness",
                  help="Enter the compactness measure for the generated districts",
                  default=1.0,
                  type="double")
p <- add_argument(p,
                  "--resample",
                  help="Including this flag will set the resampling to true",
                  flag=TRUE)
p <- add_argument(p,
                  "--adapt_k_thresh",
                  help="Enter the threshold value used in teh heuristic to select a value ki for each splitting iteration",
                  default=0.985,
                  type="double")
p <- add_argument(p,
                  "--seq_alpha",
                  help="Enter the amount to adjust the weights by at each resampling step.",
                  default=0.5,
                  type="double")
p <- add_argument(p,
                  "--pop_temper",
                  help="Enter the strength of the automatic population tempering",
                  default=0.0,
                  type="double")
p <- add_argument(p,
                  "--final_infl",
                  help="Enter the multiplier for the population constraint",
                  default=1,
                  type="double")
p <- add_argument(p,
                  "--est_label_mult",
                  help="Enter the multiplier for the number of importance samples",
                  default=1.0,
                  type="double")
p <- add_argument(p,
                  "--verbose",
                  help="Including this flag will create.",
                  flag=TRUE)
p <- add_argument(p,
                  "--silent",
                  help="Including this flag will suppress all information while sampling.",
                  flag=TRUE)
p <- add_argument(p,
                  "--dont_adjust_labels",
                  help="Turns on the sequential label adjuster",
                  flag=TRUE)


# OTHER FLAGS FOR DATA PROCESSING AND REPRODUCIBILITY
p <- add_argument(p, 
                  "--rng_seed", 
                  help="Enter the rng seed for the run",
                  default=42, 
                  type="integer")
p <- add_argument(p, 
                  "--tally_cols", 
                  help="Enter the names of the columns that you would like to tally",
                  default="DO_NOT_TALLY",
                  type="character",
                  nargs="+")
p <- add_argument(p,
                  "--output_file",
                  help="Enter the name of the output file.",
                  default="test_ouput.csv",
                  type="character")



argv <- parse_args(p)


if (is.na(argv$rds_map)) {
    if (is.na(argv$shapefile)) {
        stop("You must provide either a shapefile or an rds_map")
    }
    output_messages <- capture.output(
    vtds <- st_read(dsn = paste0("./", argv$shapefile))
    )

    population <- sum(vtds[[argv$pop_col]])

    if (is.null(argv$pop_bounds) || length(argv$pop_bounds) != 3) {
        argv$pop_bounds <- NULL
    }
} else{
    output_messages <- paste("Reading in map from ", argv$rds_map)
}


if (argv$dont_adjust_labels){
    options("redist.adjust_labels" = FALSE)
} else {
    options("redist.adjust_labels" = TRUE)
}

cat(paste0("{\"settings\":\"", 
        paste(output_messages, collapse = "\n"), 
        "\nredist.adjust_labels:\t",
        getOption("redist.adjust_labels"),
        "\"}\n"))

if (!is.na(argv$rds_map)) {
    map <- readRDS(argv$rds_map)
} else {
    map <- redist_map(vtds, 
                      pop_tol=argv$pop_tol, 
                      total_pop=argv$pop_col, 
                      ndists=argv$n_dists,
                      pop_bounds=argv$pop_bounds);
}

set.seed(argv$rng_seed)
plans <- redist_smc(map,
                    nsims=argv$n_sims,
                    compactness=argv$compactness,
                    resample=argv$resample,
                    adapt_k_thresh=argv$adapt_k_thresh,
                    seq_alpha=argv$seq_alpha,
                    pop_temper=argv$pop_temper,
                    ncores=16L,
                    final_infl=argv$final_infl,
                    est_label_mult=argv$est_label_mult,
                    verbose=argv$verbose,
                    silent=argv$silent)

tally_list <- strsplit(argv$tally_cols,",")[[1]]


if(tally_list[1] != "DO_NOT_TALLY") {
    for(thing in tally_list) {
        plans = plans %>%
            mutate(tally_var(seed, !!rlang::sym(thing)))
    }
}

plans_mat <- t(as.matrix(plans))

plans_list <- lapply(1:nrow(plans_mat), function(i) as.vector(plans_mat[i,]))


json_data <- list(step = argv$n_dists, final_wgts = weights(plans))#, districts = plans_list)
json_output <- toJSON(json_data, auto_unbox = TRUE)

cat(paste0("\n",json_output))

final_summary <- capture.output(summary(plans))

cat("\n{\"summary\": \"", paste(final_summary, collapse = "\n"), "\"}")

file_name <- paste0("./", argv$output_file)
write.csv(plans, file_name)