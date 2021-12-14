#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 8G
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J p05_blibnumber
#SBATCH -o stdout_pa05_blibnumber_limblast.txt
#SBATCH -e stderr_pa05_blibnumber_limblast.txt


##source activate YOUR_CONDA_ENV
##source /com/extra/R/3.5.0/load.sh
#load modules required
module purge
#module load python/v2.7.12
#module load cutadapt/v1.11
#module load vsearch/v2.8.0


# load the R module 'dada2' package for R requires R v3.4
#module load R/v3.4.3
# in July-2021 dada2 will only install in R v4.0.2. with the aid from "BiocManager"
# ## https://www.bioconductor.org/packages/release/bioc/html/dada2.html
module load R/v4.0.2
# run the R code
srun part05_limitBLASTresults_before_taxonomyB_v01_blibnumber.r