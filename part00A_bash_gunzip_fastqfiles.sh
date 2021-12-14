#!/bin/bash
# -*- coding: utf-8 -*-

#get working directory and place in variable
WD=$(pwd)

# define input directory with 'fastq.gz' files 
INDR1="00A_raw_zipped_fastq.gz_files"
# define output directory where the  unzipped 'fastq.gz' files are to be placed 
OUDR1="00B_raw_decompressed_fastq.gz_files"

# remove the previous version of the output directory
rm -rf "${OUDR1}"
# make a new version of the output directory
mkdir -p "${OUDR1}"
# In order to keep the original gz files you can gunzip them to a different directory:
# See this website: https://superuser.com/questions/139419/how-do-i-gunzip-to-a-different-destination-directory
# gunzip -c file.gz > /THERE/file

# Iterate over uncompressed files
for f in "${WD}"/"${INDR1}"/b0*_R*
do
	#echo $f
	#modify the filename with the sed command, to delete the end of the file name
	nf=$(echo $f | sed -E 's/^.*[/]//g' | sed 's/.gz//g')
	echo $nf
	#modify the path name with the sed command, to delete the last sub directory
	SWD=$(echo $WD | sed -E 's;(.*)\\/.*$;\1;g')
	#echo ""${SWD}"/"${OUDR1}""
	#uncompress the gz files
	gunzip -c "$f" > ""${SWD}"/"${OUDR1}""/$nf
	# and character modify the uncompressed file
	chmod 755 ""${SWD}"/"${OUDR1}""/$nf
done