#!/bin/bash
# -*- coding: utf-8 -*-

# Important. This bash code makes use of the gunzip files resulting from the NGS sequencing
# A list of the gunzip files is needed for the iterations below, as the loop over the numbers 
# then needs the gunzip file names to make lists of the files
# To get this working locally without fetching all the large gunzip files, I started out by:
# 1.
# Using sftp to fetch the raw fastg.gz files from the NGS sequencing center. Using the sftp command I
# got these files placed in a directory on the remote server.
# by logging in to the remote HPC server first
# $ ssh phq599@fend01.hpc.ku.dk
# Then making a directory
# $ mkdir /groups/hologenomics/phq599/data/EBIODIV_2021jun25
# Then navigating into this directory:
# $ cd /groups/hologenomics/phq599/data/EBIODIV_2021jun25
# Then making a directory
# $ mkdir 00A_raw_zipped_fastq.gz_files
# Then navigating into this directory:
# $ cd 00A_raw_zipped_fastq.gz_files
# Then loggin in to sftp
# $ sftp phq599@seqsftp.science.ku.dk:/home/phq599/210614_M01168_0197_000000000-JR5WW_MNYDF/SWKeBIODIV2021jun07
# Then getting all the files down into the '00A_raw_zipped_fastq.gz_files' directory
# by using the command 'mget' to get multiple files.
# I can then exit the sftp with 'exit'
# $ exit
# 2.
# After I exited the sftp I used the 'ls' command on the remote server in this directory
# where the raw fastg.gz files where. I could then write this list to a file
# like this:
# $ ls > list_of_fastq.gz_files.txt
# And I could then use the 'scp' command to get this tiny file down locally
# This file (ie. 'list_of_fastq.gz_files.txt') is pretty useless, but it does holds the names of the files
# I am about to work on.
# 3.
# I could then locally run this line: 
# $ for i in $(cut -f 9 -d' ' list_of_fastq.gz_files.txt); do echo "empty" > $i; done
# Which is a small loop that generates files that have the same name as the files on the remote server
# but these files only have the text 'empty' inside.
# Later on I combined this information to fetch the fastq.gz filenames in the remote directory
#

#put present working directory in a variable
WD=$(pwd)
REMDIR="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
WD="${REMDIR}"
#define inpout directory
INDIR01="00B_raw_decompressed_fastq.gz_files"
INDIR02=$(echo ""${REMDIR}"/"${INDIR01}"")
#define output directory
OUDIR01="out01_batch_lst_files"
OUDIR01="01_demultiplex_filtered"
#Make a new output file directory
rm -rf "$OUDIR01"
mkdir "$OUDIR01"

#INDR1="ebiodiv_2021jun"
#PATH01=""$PATH01""
#PATH01="/home/sknu003/no_backup_uoa00029/JMS_raw_NGSdata2019"
PATH01=$(echo ""${REMDIR}"/"${OUDIR01}"")

#_______________________________________________________________________________________________________________________

# Primers are adopted from :		DiBattista et al., 2017. Assessing the utility of eDNA as a tool to survey reef-fish communities in the Red Sea.  Coral Reefs . DOI 10.1007/s00338-017-1618-1.
#	16SFDiBat	GACCCTATGGAGCTTTAGAC
#	16S2RdDiBat	CGCTGTTATCCCTADRGTAACT
PRIMSET_16SDiBat="GACCCTATGGAGCTTTAGAC CGCTGTTATCCCTADRGTAACT" #16SDiBat primer set

# Primers are adopted from :		Miya M, Sato Y, Fukunaga T, Sado T, Poulsen JY, Sato K, Minamoto T, Yamamoto S, Yamanaka H, Araki H, Kondoh M, Iwasaki W. MiFish, a set of universal PCR primers for metabarcoding environmental DNA from fishes: detection of more than 230 subtropical marine species. R Soc Open Sci. 2015 Jul 22;2(7):150088. doi: 10.1098/rsos.150088. eCollection 2015 Jul. PubMed PMID: 26587265; PubMed Central  PMCID: PMC4632578.  
#	MiFiUF12s_Mi	GTCGGTAAAACTCGTGCCAGC
#	MiFiUR12s_Mi	CATAGTGGGGTATCTAATCCCAGTTTG
PRIMSET_MiFiU12s="GTCGGTAAAACTCGTGCCAGC CATAGTGGGGTATCTAATCCCAGTTTG" #MiFiU12s primer set

# Primers are adopted from :		Miya M, Sato Y, Fukunaga T, Sado T, Poulsen JY, Sato K, Minamoto T, Yamamoto S, Yamanaka H, Araki H, Kondoh M, Iwasaki W. MiFish, a set of universal PCR primers for metabarcoding environmental DNA from fishes: detection of more than 230 subtropical marine species. R Soc Open Sci. 2015 Jul 22;2(7):150088. doi: 10.1098/rsos.150088. eCollection 2015 Jul. PubMed PMID: 26587265; PubMed Central  PMCID: PMC4632578.  	
#	MiFiEF12s_Mi	GTTGGTAAATCTCGTGCCAGC
#	MiFiER12s_Mi	CATAGTGGGGTATCTAATCCTAGTTTG

# Primers are adopted from :		Valentini et al. 2016. Next-generation monitoring of aquatic biodiversity using environmental DNA metabarcoding. Molecular Ecology (2016) 25, 929–942.
#	teleo_F	ACACCGCCCGTCACTCT
#	teleo_R	CTTCCGGTACACTTACCATG

# This metabarcode sequencing setup used
# 16SDiBat 	primerset for b013-b016
# MiFiU 	primerset for b009-b012
TAGS_16SDiBat="part01A_tag33_44_16SDiBat.txt"
TAGS_MiFiU="part01A_tag45_56_MiFiU.txt"

# Prepare the '.txt' files with list of tags like this. Notice that the tags are repeated twice, as you have used
# twin tags (also known as  paired tags)
# Also notice the name if the sample does not include any points, and the underscores used makes the sample names
# equal 3 columns, one for the sample, one for primerset and one for the tag number
# Do not introduce additional underscores in the sample  names, or in the primerset names, as this will influence
# whether the demulitplex step with DADA2 is able to work
# The first column denotes your sample names you want associated with the tags, 
# the second and third
# column denotes your tags used in combination. Note that since this NGS data file has been 
# prepared to have matching tags in both F- and R- primer the second and third column 
# match each other

# IMPORTANT ! 
# This tags.txt file must have a an end-of-line character at the end of the very
# last line of tags.
# If this last end-of-line is not included the 'dada2_demultiplexing_v2.sh' part will not take this
# last tag combination into consideration. Also. If you add to many unnecessary end-of-lines at the end
# the 'dada2_demultiplexing_v2.sh' code will start assigning NGS reads to non-existing tags. In other
# words you need exactly one end-of-line character added after the very last line of tags.
# You can check that your 'tags.txt' file has this extra end-of-line by inspecting the 
# 'tags.txt'
# file in a text-editor. You should see the last line with tags having a number in the text-editor. 
# You should also be able to see that the next line also is assigned a number in the text-editor 
# margin. But also note that there are no more empty lines afterwards.

# Example of the tag list file: "part01A_tag45_56_MiFiU.txt"
#_______________________________________________________________________________________________________________________

# MST107_MiFiU_tag45	CTATAA	CTATAA
# MST107_MiFiU_tag46	AATGAA	AATGAA
# MST109_MiFiU_tag47	CGAATC	CGAATC
# MST109_MiFiU_tag48	AGAGAC	AGAGAC
# MST110_MiFiU_tag49	TTCGGA	TTCGGA
# MST110_MiFiU_tag50	CGACGT	CGACGT
# MST221_MiFiU_tag51	CTCATG	CTCATG
# MST221_MiFiU_tag52	TGTATA	TGTATA
# MST235_MiFiU_tag53	ACAACC	ACAACC
# MST235_MiFiU_tag54	TCAGAG	TCAGAG
# NC_MiFiU_tag55	GTAGTG	GTAGTG
# PCMock_MiFiU_tag56	AGCACT	AGCACT
#
#_______________________________________________________________________________________________________________________

# Example of the tag list file: "part01A_tag33_44_16SDiBat.txt"
#_______________________________________________________________________________________________________________________

# MST107_DiBat_tag33	AAGGTC	AAGGTC
# MST107_DiBat_tag34	GGCGCA	GGCGCA
# MST109_DiBat_tag35	TCGACG	TCGACG
# MST109_DiBat_tag36	CCTGTC	CCTGTC
# MST110_DiBat_tag37	AGAAGA	AGAAGA
# MST110_DiBat_tag38	AATAGG	AATAGG
# MST221_DiBat_tag39	GGTTCT	GGTTCT
# MST221_DiBat_tag40	TAATGA	TAATGA
# MST235_DiBat_tag41	GTAACA	GTAACA
# MST235_DiBat_tag42	AATCCT	AATCCT
# NC_DiBat_tag43	AGACCG	AGACCG
# PCMock_DiBat_tag44	TGGCGG	TGGCGG

#_______________________________________________________________________________________________________________________


# #prepare paths to files, and make a line with primer set and number of nucleotide overlap between paired end sequencing
# Iteration loop for the MiFiU primerset
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
# do this for 009 to 012 for the MiFiU primerset
	for fn in $(seq -f "%03g" 9 12)
do
	#echo $fn
	FASTQF01=$(ls "${INDIR02}" | grep "$fn" | grep 'R1' | sed -E 's/\.gz//g')
	#echo "$FASTQF01"
	FASTQF02=$(ls "${INDIR02}" | grep "$fn" | grep 'R2' | sed -E 's/\.gz//g')
	#echo "$FASTQF02"
	# make an output file name with the number iterated over
	OUTLSTF01=$(echo "part01A_batch_file_ebiodiv_b"${fn}".list")
	#make a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	#make a directory for the NGS library
	rm -rf "${PATH01}"/"${BDR}"
	mkdir -p "${PATH01}"/"${BDR}"
	# put varaibles together and write the the line to a file, notice the number of nucleotide overlapping requested
	# also notice the new-line at the end of the line (i.e. after the number of nucleotides needed to be overlapping)
	# that includes all variables, this is needed for the demultiplexing part
	# later on. Without this new-line the demultiplexing part will not work
echo ""${INDIR02}"/"${FASTQF01}" "${INDIR02}"/"${FASTQF02}" "${TAGS_MiFiU}" "${PRIMSET_MiFiU12s}" 5
" > "${PATH01}"/"${BDR}"/"${OUTLSTF01}"
	# copy tags file into the b000 directory
	cat "${TAGS_MiFiU}" | \
	  # replace the odd characters
            # https://unix.stackexchange.com/questions/381230/how-can-i-remove-the-bom-from-a-utf-8-file
            LC_ALL=C sed 's/\xEF\xBB\xBF//g' | \
            # replace the odd characters : https://superuser.com/questions/207207/how-can-i-delete-u200b-zero-width-space-using-sed
            LC_ALL=C sed 's/\xe2\x80\x8b//g' > "${PATH01}"/"${BDR}"/"${TAGS_MiFiU}"
#end iteration over numbers
done

# #prepare paths to files, and make a line with primer set and number of nucleotide overlap between paired end sequencing
# Iteration loop for the 16SDiBat primerset
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
# do this for 013 to 016 for the 16SDiBat primerset
	for fn in $(seq -f "%03g" 13 16)
do
	#echo $fn
	FASTQF01=$(ls "${INDIR02}" | grep "$fn" | grep 'R1' | sed -E 's/\.gz//g')
	#echo "$FASTQF01"
	FASTQF02=$(ls "${INDIR02}" | grep "$fn" | grep 'R2' | sed -E 's/\.gz//g')
	#echo "$FASTQF02"
	# make an output file name with the number iterated over
	OUTLSTF01=$(echo "part01A_batch_file_ebiodiv_b"${fn}".list")
	#make a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	#make a directory for the NGS library
	rm -rf "${PATH01}"/"${BDR}"
	mkdir -p "${PATH01}"/"${BDR}"
	# put varaibles together and write the the line to a file, notice the number of nucleotide overlapping requested
	# also notice the new-line at the end of the line (i.e. after the number of nucleotides needed to be overlapping)
	# that includes all variables, this is needed for the demultiplexing part
	# later on. Without this new-line the demultiplexing part will not work
echo ""${INDIR02}"/"${FASTQF01}" "${INDIR02}"/"${FASTQF02}" "${TAGS_16SDiBat}" "${PRIMSET_16SDiBat}" 5
" > "${PATH01}"/"${BDR}"/"${OUTLSTF01}"
	# write the tags file into the b000 directory 
	cat "${TAGS_16SDiBat}" | \
	  				# replace the odd characters
            # https://unix.stackexchange.com/questions/381230/how-can-i-remove-the-bom-from-a-utf-8-file
            LC_ALL=C sed 's/\xEF\xBB\xBF//g' | \
            # replace the odd characters : https://superuser.com/questions/207207/how-can-i-delete-u200b-zero-width-space-using-sed
            LC_ALL=C sed 's/\xe2\x80\x8b//g' > "${PATH01}"/"${BDR}"/"${TAGS_16SDiBat}"
#end iteration over numbers
done

#_______________________________________________________________________________________________________________________

# To make slurm submission scripts inside each directory where tags files and batch files are placed
# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
for fn in $(seq -f "%03g" 9 16)
	do
#make a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	# now print the slurm submission sbatch file, that you will use to submit the slurm run
printf "#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 4G
#SBATCH -c 1
#SBATCH -t 4:00:00
#SBATCH -J pa01B_demulti_b"${fn}"
#SBATCH -o stdout_pa01B_demulplex_b"${fn}".txt
#SBATCH -e stderr_pa01B_demulplex_b"${fn}".txt


## Activating the shell script: 'part01B_dada2_demultiplexing_v3_b"${fn}".sh  
## will call upon two additional files as input files for the demultiplex process.
## In this case these files are :
## "part01A_batch_file_ebiodiv_b"${fn}".list"
## and
## part01B_tags.txt
## Make sure these files also are available in the same directory as where you place
## the file 'part01B_dada2_demultiplexing_v3_b"${fn}".sh'
## Equally important ! Also make sure that these two files hold :
## I) The right path to the correctt input files - i.e. the raw NGS read
## II) The correct filename for the lsit of matching tags and names of samples
## III) The correct metabarcode primers you used originally for the tagged PCR
## The shell scrip you are about to activate with this slurm submission code will not work if these
## pieces of information are not matching

##source activate YOUR_CONDA_ENV # if you are using a conda environment at AU , not at UCPH
## Instead on HPC at UCPH load the required modules
module load python/v2.7.12
module load cutadapt/v1.11
module load vsearch/v2.8.0

#run the shell script
# notice the use of the slurm command 'srun'
srun part01B_dada2_demultiplexing_v3_b"${fn}".sh" > "${PATH01}"/"${BDR}"/part01B_sbatch_run_dada2_demultiplexing_v3_b"${fn}".sh

#> "${OUDIR01}"/part01B_dada2_demultiplexing_v3_b"${fn}".sh

#end iteration over sequence of numbers
done
# 
#_______________________________________________________________________________________________________________________



#_______________________________________________________________________________________________________________________

# To make DADA2 demultiplexing sh scripts
# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
for fn in $(seq -f "%03g" 9 16)
	do
	#define a directory name for the NGS library
	BDR=$(echo "b"${fn}"")
	# write the contents with cat
	cat part01B_dada2_demultiplexing_v3.sh | \
	# and use sed to replace a txt string w the b library number
	sed "s/b_library_number/b"${fn}"/g" > "${PATH01}"/"${BDR}"/part01B_dada2_demultiplexing_v3_b"${fn}".sh
	#make the DADA2 sh script executable
	chmod 755 "${PATH01}"/"${BDR}"/part01B_dada2_demultiplexing_v3_b"${fn}".sh

	done
#_______________________________________________________________________________________________________________________




#_______________________________________________________________________________________________________________________

# write a sh script that can start all slurm submissions of the DADA2 demultiplex script in one go
# making this overall script executable, will make it possible to start all individual slurm submission scripts for
# part01B in one go, by just executing this resulting script

# Notice the use of backslash to escape the dollar sign and the double quotes in the printf command
# Also notice the use of double percentage symbols to escape the percentage symbol in the part where you need to pad 
# with zeroes
# https://unix.stackexchange.com/questions/519315/using-printf-to-print-variable-containing-percent-sign-results-in-bash-p
printf "#!/bin/bash
# -*- coding: utf-8 -*-

# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
for fn in \$(seq -f \"%%03g\" 9 16)
	do
		#define a directory name for the NGS library
		BDR=\$(echo \"b\"\${fn}\"\")
		cd "${PATH01}"/\"\${BDR}\"
		sbatch part01B_sbatch_run_dada2_demultiplexing_v3_b\"\${fn}\".sh
		cd "${WD}"
	done
	 " > "${WD}"/part01B_bash_start_all_demultiplexing_v3.sh

#change back to the working directory
cd "${WD}"
#make it executable
chmod 755 part01B_bash_start_all_demultiplexing_v3.sh

# Instructions:
# now use these commands locally:
# $ rm -rf part01.tar.gz 
# $ tar -zcvf part01.tar.gz part01*
# $ scp part01.tar.gz phq599@fend01.hpc.ku.dk:/groups/hologenomics/phq599/data/EBIODIV_2021jun25/.

# On the remote server execute this command:
# $ tar -zxvf part01.tar.gz 

# Once uncompressed then first execute:

# $ ./part01A_bash_make_batch_lists_ebiodiv01.sh 

echo " 
Instructions:

After you have run ./part01A_bash_make_batch_lists_ebiodiv01.sh 
Then execute:
./part01B_bash_start_all_demultiplexing_v3.sh 

  "

#
#