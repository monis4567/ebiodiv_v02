#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 16G
#SBATCH -c 4
#SBATCH -t 4:00:00
#SBATCH -J p06_blibnumber
#SBATCH -o stdout_pa06_blibnumber_limblast.txt
#SBATCH -e stderr_pa06_blibnumber_limblast.txt


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
#srun part06_my_taxonomy_B_v01_blibnumber.r
#srun part06_my_taxonomy_MRJ_20200130_v01_blibnumber.r
srun part06_my_taxonomy_v07_blibnumber.r

#Line to use for cancelling multiple jobs
#NJOBS=$(seq 26077621 26077628); for i in $NJOBS; do scancel $i; done

#use these lines to check all stdouts for skipped or failed attempts
# for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";grep ook -B1 ./01_demultiplex_filtered/b"${fn}"/stdout_pa06_b"${fn}"_limblast.txt;done
# for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";grep ook -A2 ./01_demultiplex_filtered/b"${fn}"/stdout_pa06_b"${fn}"_limblast.txt;done
# for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";grep Skip -A2 ./01_demultiplex_filtered/b"${fn}"/stdout_pa06_b"${fn}"_limblast.txt;done
# for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";grep HT -a4 ./01_demultiplex_filtered/b"${fn}"/stdout_pa06_b"${fn}"_limblast.txt;done

# use this line to remove old versions of part06 codes
# for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";cd ./01_demultiplex_filtered/b"${fn}"/; rm *part06*;cd /groups/hologenomics/phq599/data/EBIODIV_2021jun25;done