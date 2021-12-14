#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 48G ### or try with 8G if 4G is not enough
#SBATCH -c 1
#SBATCH -t 6:00:00
#SBATCH -J p04_blibnumber
#SBATCH -o stdout_pa04_blast_blibnumber.txt
#SBATCH -e stderr_pa04_blast_blibnumber.txt

#load modules required
module purge


# you can check what module is available with the command:
# module avail
# But if you know that you want to look for 'blast' then instead try:
# module spider blast
# This will tell you which of the remote applications has any similarity 
# in naming with your search  

# Load the correct module
module load blast+/v2.8.1
# The older versions of blast+ might not be able to perform the remote search operation. 
# see this question : https://www.biostars.org/p/296360/
#module load blast/v2.2.26

###________________________________________________________________________________________________________________________
###  02.01 try a global blast search on less than 10 sequences - start
###________________________________________________________________________________________________________________________


#looking at this website: https://www.ncbi.nlm.nih.gov/books/NBK279680/
# I found this line: 

#To send the search to our servers and databases, add the –remote option:
#blastn –db nt –query nt.fsa –out results.out -remote 

#IMPORTANT !!!! I could not get this line working.
# I kept getting this error: "Error:  (CArgException::eSynopsis) Too many positional arguments (1), the offending value: "
# I then looked here: http://www.metagenomics.wiki/tools/blast/error-too-many-positional-arguments
# Replacing the dashes I accidentally copied from the website made it work. I also noticed that the arguments following the dashes
# changed color in my text editor when I replaced the dashes. You can copy the lines from the section below instead 

## define the input filename
INPFNM1="DADA2_nochim.otus"
INPFNM2="DADA2_raw.otus"
## define the output filename
#OUTFLN1="blast_result_AMRH_MBIB_AL.results.01.txt"
#OUTFLN1="part04_blast_result_AMRH_AL.results.01.txt"
OUTFLN1="part04_blast_blibnumber.results.01.txt"
OUTFLN2="part04_blibnumber.DADA2_nochim.otus.fas"
#remove any previous versions of the output file
rm -rf "${OUTFLN1}"
## just to start out. Try only with the very first sequence in the file of all sequences. Just to see if it works
#Here I use the head command to get the first 2 lines of the file, and plcae it in a new file
#head -20 "${INPFNM1}" > seq3_test.fas
cat "${INPFNM1}" > "${OUTFLN2}" 
##I then use this new file as a variable to try out the blastn on the remote database
#INPFNM1="seq3_test.fas"
#
## try out with an unrestrcited search against the remote database
#blastn -db nt -query "${INPFNM2}" -out results01.out -remote
## try out a more restricted search -  NOTE ! the '-max_target_seqs' only limits the search to return the first 40
## matches. This does not mean the best 40 matches - see this publication :  https://academic.oup.com/bioinformatics/article/35/9/1613/5106166
##Instead of using the '-max_target_seqs', consider using the evalue argument '[-evalue evalue]' : https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=FAQ#expect
#blastn -db nt -max_target_seqs 40 -outfmt "6 std qlen qcovs sgi sseq ssciname staxid" -out results02.out -qcov_hsp_perc 90 -perc_identity 80 -query "${INPFNM2}"
## here is a third blast search on the remote database with a different evalue setting
#blastn -db nt -evalue 1 -outfmt "6 std qlen qcovs sgi sseq ssciname staxid" -out results03.out -qcov_hsp_perc 90 -perc_identity 80 -query "${INPFNM2}"

## And a fourth blast search on the remote database with a different evalue setting
#blastn -db nt -evalue 0.0001 -outfmt "6 std qlen qcovs sgi sseq ssciname staxid" -out results04.out -qcov_hsp_perc 90 -perc_identity 80 -query "${INPFNM2}"

# NOTE ! These 4 searches on 1 seq here took about 40 minutes of run time using slurm submission queue system
# I tried writing out the first four lines of the "DADA2_nochim.otus" file by using the 'head -8' command
# to see how long this takes
# Doing the same 4 searches on two sequences (seq1 and seq2) took 39 minutes
# Trying the same 4 searches on 4 sequences (seq1 , seq2, seq3 and seq4) took 42 minutes
# I then tried with 'head -20' to get the first 10 sequences in the "DADA2_nochim.otus" file, and check how fast this 
# would be able to finish. A search with 10 sequences finished in 33 minutes.
# Theses results are not very useful for further analysis, but it gave me an idea on how I can start with minor
# tests of my input data, and what the outcome of this would be, and it allowed me to check how long time a different
# number of sequences might take to analyse.
# In the part below I have 


# You can check the results file with the aid of the unix 'cut' command.
# Like this:
# cut -d$'\t' -f1,17 results02.out | head -300 | uniq
# Or like this:
# cut -d$'\t' -f1,17 results02.out | uniq | wc -l
# The last line will help you see how many unique lines of species names you have found for each 
# sequence you have blasted.
# Or check with this pipe of commands
# cut -d$'\t' -f1,11,17 results05.out | head -20
# to see evalues

# Try this line:
# cut -d$'\t' -f2 blast_result_JMS_FL.results.01.txt | cut -d'.' -f1
# to see only accession numbers matching each sequence that is matched in the blast search
# try writing these accession numbers to a new file
# cut -d$'\t' -f2 blast_result_JMS_FL.results.01.txt | cut -d'.' -f1 > blast_result_JMS_FL.results.02_acc_nos.txt
# or try:
 # cut -d$'\t' -f17 blast_result_AMRH_MBIB_AL.results.01.txt | cut -d'.' -f1 | sort | uniq | head -4
 # cut -d$'\t' -f17 part04_blast_result_AMRH_MBIB_CL.results.01.txt | cut -d'.' -f1 | sort | uniq | grep "^V" | head -5
# Now you can modify these two lines to something similar. Read up on how the 'cut' and the 'uniq' and 'wc' command works, 
# and check the internet how you can specify
# fields' with '-f' and what delimiter with '-d' to cut by
# A quick search on the internet lead me here, where there is more about the delimiter argument for the 'cut' command
# https://unix.stackexchange.com/questions/35369/how-to-define-tab-delimiter-with-cut-in-bash

###________________________________________________________________________________________________________________________
###  02.01 try a global blast search on less than 10 sequences - end
###________________________________________________________________________________________________________________________

###________________________________________________________________________________________________________________________
###  02.02 try a global blast search on all sequences in the 'nochim' file - start
###________________________________________________________________________________________________________________________

blastn -db nt -max_target_seqs 3000 -outfmt "6 std qlen qcovs sgi sseq ssciname staxid" -out "${OUTFLN1}" -qcov_hsp_perc 90 -perc_identity 80 -query "${INPFNM1}"

###________________________________________________________________________________________________________________________
###  02.02 try a global blast search on all sequences in the 'nochim' file - end
###________________________________________________________________________________________________________________________





#______________second try a local blast search
#define the path to where your local database is
#LOCALDB="/faststorage/project/eDNA/blastdb/nt"
#run blast but without the '-remote' command , and with a local database instead
# notice this remarks about the '-max_target_seqs' option in this paper:  https://academic.oup.com/bioinformatics/article/35/9/1613/5106166 
#blastn -db "${LOCALDB}" -max_target_seqs 40 -outfmt "6 std qlen qcovs sgi sseq ssciname staxid" -out DADA2_nochim.10.95.blasthits -qcov_hsp_perc 90 -perc_identity 80 -query "${INPFNM1}"


