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

#define list with Positive control mock species
PCL="part05_lst_species_in_PCmock.txt"
#define list with species known in the habitat
SPL="part05_lst_species_of_marine_fish_in_DK.txt"
#define output list file name
OUL="part05_lst_species_of_fish_in_DK_and_PCMock.txt"
#concatenate the list files in to one list
cat "${SPL}" "${PCL}" > "${OUL}"
#compress the list of species files
zip part05_lst_species.zip part05_lst_species*
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
	cat part05_limitBLASTresults_before_taxonomyB_v01.r | \
	# and use sed to replace a txt string w the b library number
	# replace "blibrarynumber"
	sed "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part05_limitBLASTresults_before_taxonomyB_v01_b"${fn}".r
	#character modify the r code to make it possible to execute the file
	chmod 755 "${PATH01}"/"${BDR}"/part05_limitBLASTresults_before_taxonomyB_v01_b"${fn}".r

	#also replace in the slurm submission script
	cat part05_sbatch_run_limBLAST_v01.sh | \
	# and use sed to replace a txt string w the b library number
	# replace "blibrarynumber"
	sed "s/blibnumber/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part05_sbatch_run_limBLAST_v01_b"${fn}".sh
	# remove any previous versions of the list of species
	rm "${PATH01}"/"${BDR}"/part05_lst_species*
	#copy the zipped file with list of species
	cp part05_lst_species.zip "${PATH01}"/"${BDR}"/.
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
	#uncompress the lists with species
	unzip part05_lst_species.zip
	# start the slurm sbatch code
	sbatch part05_sbatch_run_limBLAST_v01_b"${fn}".sh
	# change directory to the working directory
	cd "${WD}"
# end iteration over sequence of numbers	
done


#
#
#