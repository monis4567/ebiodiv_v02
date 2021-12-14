#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
#REMDIR="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
REMDIR="${WD}"
#define input directory
OUDIR01="01_demultiplex_filtered"

RFILE01="part06_my_taxonomy_MRJ_20200130_v01.r"
RFILE01="part06_my_taxonomy_v07.r"
RFILE02=$(echo "${RFILE01}" | sed 's/\.r//g')
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
	cat "${RFILE01}" | \
	# and use sed to replace a txt string w the b library number
	# replace "blibrarynumber"
	sed "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/"${RFILE02}"_b"${fn}".r
	#character modify the r code to make it possible to execute the file
	chmod 755 "${PATH01}"/"${BDR}"/"${RFILE02}"_b"${fn}".r

	#also replace in the slurm submission script
	cat part06_sbatch_run_mytaxonomyB_v01.sh | \
	# and use sed to replace a txt string w the b library number
	# replace "blibrarynumber"
	sed "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part06_sbatch_run_mytaxonomyB_v01_b"${fn}".sh
	
	# and copy the merge IDtax list
	cp part06_MergedTaxIDs.txt "${PATH01}"/"${BDR}"/part06_MergedTaxIDs.txt
	# and copy the R functions file  
	cp part06_functions_taxonomy_functions.R "${PATH01}"/"${BDR}"/part06_functions_taxonomy_functions.R
# end iteration over sequence of numbers	
done

# Iteration loop over b library numbers
# to prepare slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
	for fn in $(seq -f "%03g" 9 16)
do
	#get the subdirectory name
	BDR=$(echo "b"${fn}"")
	# change directory to the subdirectory
	cd "${PATH01}"/"${BDR}"
	# start the slurm sbatch code
	sbatch part06_sbatch_run_mytaxonomyB_v01_b"${fn}".sh
	# change directory to the working directory
	cd "${WD}"
# end iteration over sequence of numbers	
done


# # After having completed
# OUTF02="part06 my_classified_otus.filt_BLAST_results_allbibs.txt"
# OUTF03="part06 my_classified_otus.filt_BLAST_results_allbibs02.txt"
# #remove any previous versions of the outputfile
# rm "$WD"/"$OUTF02"
# #write a new output file to write to
# touch "$WD"/"$OUTF02"
# iconv -f UTF-8 -t UTF-8 "$WD"/"$OUTF02"

# # Iteration loop over b library numbers
# # to collect results  for each b library number
# #iterate over sequence of numbers
# # but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
# 	for fn in $(seq -f "%03g" 9 16)
# do
# 	#get the subdirectory name
# 	BDR=$(echo "b"${fn}"")
# 	# change directory to the subdirectory
# 	cd "${PATH01}"/"${BDR}"
# 	# start the slurm sbatch code
# 	cat part06_my_classified_otus_b"${fn}".filt_BLAST_results.txt | cut -d$'\t' -f15 | uniq >> "$WD"/"$OUTF02"
# 	# change directory to the working directory
# 	cd "${WD}"
# # end iteration over sequence of numbers	
# done

# cd $WD
# cat "$OUTF02" | uniq > OUTF03

# # cat part06_my_classified_otus_b012.02.filt_BLAST_results.txt | cut -d$'\t' -f15 | uniq
# # part06_my_classified_otus_b012.02.filt_BLAST_results.txt
# #