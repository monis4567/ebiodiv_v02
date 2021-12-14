#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)


# use a one line to get all resulting pdfs in a compressed file
#WD="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"; for fn in $(seq -f "%03g" 9 16);do echo "b"${fn}"";cd ./01_demultiplex_filtered/b"${fn}"/; cp *part07*pdf "${WD}"/.;cd "${WD}";done; tar -zcvf part07_plots.pdf.tar.gz part07_*stacked*pdf; rm part07_*stacked*pdf
WD="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
for fn in $(seq -f "%03g" 9 16)
	do 
		echo "b"${fn}""
		cd ./01_demultiplex_filtered/b"${fn}"/
		cp *part07*pdf "${WD}"/.
		cd "${WD}"
	done
tar -zcvf part07_plots.pdf.tar.gz part07_*stacked*pdf; rm part07_*stacked*pdf

#
# use a one line to get all resulting csv files in a compressed file
#WD="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"; for fn in $(seq -f "%03g" 9 16);do echo "b"${fn}"";cd ./01_demultiplex_filtered/b"${fn}"/; cp *part07*csv "${WD}"/.;cd "${WD}";done; tar -zcvf part07_csv_files.tar.gz part07_*csv; rm part07_*csv
WD="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
for fn in $(seq -f "%03g" 9 16)
do
	echo "b"${fn}""
	cd ./01_demultiplex_filtered/b"${fn}"/
	cp *part07*csv "${WD}"/.
	cd "${WD}"
done
tar -zcvf part07_csv_files.tar.gz part07_*csv; rm part07_*csv

#
#