#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
REMDIR="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
#define input directory
OUDIR01="01_demultiplex_filtered"

#define path for b_library numbers
PATH01=$(echo ""${REMDIR}"/"${OUDIR01}"")

# #prepare paths to files, and make a line with primer set and number of nucleotide overlap between paired end sequencing
# Iteration loop over b library numbers
# to prepare slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
	for fn in $(seq -f "%03g" 9 16)
do
	#echo $fn
	#make a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	# write the contents with cat
	cat part02_sbatch_run_dada2_sickle_R_v01.sh | \
	# and use sed to replace a txt string w the b library number
	sed "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part02_sbatch_run_dada2_sickle_R_v01_b"${fn}".sh
	
	# and modify the R file
	cat part02_dada2_sickle_inR_v03.r | \
	# and modify inside the file
	# modify the #set min length for the 'fastqPairedFilter' function
	sed -E "s;fpfml <- 100;fpfml <- 50;g" | \
	# modify the  #set length for sickle
	sed -E "s;lsick <- 100;lsick <- 50;g" | \
	# modify the #set quality for sickle
	sed -E "s;qsick <- 28;qsick <- 2;g" | \
	# and use sed to replace a txt string w the b library number
	sed -E "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part02_dada2_sickle_inR_v03_b"${fn}".r
	#make the DADA2 sh script executable
	chmod 755 "${PATH01}"/"${BDR}"/part02_dada2_sickle_inR_v03_b"${fn}".r
done


# Iteration loop over b library numbers
# to start slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
	for fn in $(seq -f "%03g" 9 16)
do
	#echo $fn
	#make a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	#
	cd "${PATH01}"/"${BDR}"/
	#
	sbatch part02_sbatch_run_dada2_sickle_R_v01_b"${fn}".sh
	#
	cd "$WD"
done