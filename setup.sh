#!/bin/bash


R -e "install.packages(c('argparser', 'sf', 'dplyr', 'ggplot2', 'devtools', 'jsonlite'), repos='http://cran.rstudio.com/')"
git clone https://github.com/peterrrock2/redist.git 
cd redist/
git checkout tags/probs_and_generations_v1
R CMD INSTALL .
cd ..