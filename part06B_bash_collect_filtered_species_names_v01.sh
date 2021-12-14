#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
#REMDIR="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
REMDIR="${WD}"
#define input directory
OUDIR01="01_demultiplex_filtered"

#define path for b_library numbers
PATH01=$(echo ""${REMDIR}"/"${OUDIR01}"")


# After having completed
OUTF02="part06_my_classified_otus.filt_BLAST_results_allbibs.txt"
OUTF03="part06_my_classified_otus.filt_BLAST_results_allbibs02.txt"

OUTF04="part06_my_classified_otus.unfilt_BLAST_results_allbibs.txt"
OUTF05="part06_my_classified_otus.unfilt_BLAST_results_allbibs02.txt"
#remove any previous versions of the outputfile
rm "${WD}"/"${OUTF02}"
rm "${WD}"/"${OUTF03}"

rm "${WD}"/"${OUTF04}"
rm "${WD}"/"${OUTF05}"
#write a new output file to write to
touch "${WD}"/"${OUTF02}"
iconv -f UTF-8 -t UTF-8 "${WD}"/"${OUTF02}"

#write a new output file to write to
touch "${WD}"/"${OUTF04}"
iconv -f UTF-8 -t UTF-8 "${WD}"/"${OUTF04}"

# Iteration loop over b library numbers
# to collect results  for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
	for fn in $(seq -f "%03g" 9 16)
do
	#get the subdirectory name
	BDR=$(echo "b"${fn}"")
	# change directory to the subdirectory
	cd "${PATH01}"/"${BDR}"
	# write out th results file

	cat part06_my_classified_otus_b"${fn}".02.filt_BLAST_results.txt | \
	cut -d$'\t' -f9-15 | \
	uniq >> "${WD}"/"${OUTF02}"


	cat part06_my_classified_otus_b"${fn}".01.unfilt_BLAST_results.txt | \
	cut -d$'\t' -f9-15 | \
	uniq >> "${WD}"/"${OUTF04}"

	# change directory to the working directory
	cd "${WD}"
# end iteration over sequence of numbers	
done

cd ${WD}
cat "${OUTF02}" | uniq > "${OUTF03}"
cat "${OUTF04}" | uniq > "${OUTF05}"

# cat part06_my_classified_otus_b012.02.filt_BLAST_results.txt | cut -d$'\t' -f15 | uniq
# part06_my_classified_otus_b012.02.filt_BLAST_results.txt
#