
Rscript -e "install.packages('doRNG', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('servr', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('patchwork', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('argparser', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('sf', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('devtools', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('jsonlite', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('redistmetrics', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('RcppArmadillo', repos='http://cran.rstudio.com/')"
Rscript -e "install.packages('RcppThread', repos='http://cran.rstudio.com/')"

git clone https://github.com/peterrrock2/redist.git 
cd redist/
git checkout tags/probs_and_generations_v1
R CMD INSTALL .
cd ..
