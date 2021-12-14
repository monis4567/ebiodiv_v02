#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 1G
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J 00A_uncomp_raw
#SBATCH -o stdout_00A_uncomp_raw.txt
#SBATCH -e stderr_00A_uncomp_raw.txt

#load modules required
module purge
#module load python/v2.7.12
#module load cutadapt/v1.11
#module load vsearch/v2.8.0

#start the bash script that iterates over compressed gz files
srun part00A_bash_gunzip_fastqfiles.sh