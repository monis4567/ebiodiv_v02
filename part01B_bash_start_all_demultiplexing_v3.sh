#!/bin/bash
# -*- coding: utf-8 -*-

# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
for fn in $(seq -f "%03g" 9 16)
	do
		#define a directory name for the NGS library
		BDR=$(echo "b"${fn}"")
		cd /groups/hologenomics/phq599/data/EBIODIV_2021jun25/01_demultiplex_filtered/"${BDR}"
		sbatch part01B_sbatch_run_dada2_demultiplexing_v3_b"${fn}".sh
		cd /groups/hologenomics/phq599/data/EBIODIV_2021jun25
	done
	 