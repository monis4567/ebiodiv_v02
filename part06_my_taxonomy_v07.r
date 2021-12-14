#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-


###!/usr/bin/env Rscript
##args = commandArgs(trailingOnly=TRUE)

######################################################################################################################################################

# Run the taxonomy analysis of your metabarcoding data, after running it through DADA2 and BLASTN:

######################################################################################################################################################
#remove everything in the working environment, without a warning!!
rm(list=ls())

Rlibpath <- "/groups/hologenomics/phq599/data/R_packages_for_Rv4_0_2"
Sys.setenv(R_LIBS_USER=Rlibpath)
.libPaths(Rlibpath)


# #install the required package if needed:
# #install packages
# #get taxize package
# if(!require(taxize)){
#   install.packages("taxize")
# }
# library(taxize)

# wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv"
# setwd(wd00)
# getwd()

library(taxizedb)
library(tidyverse)

#source("taxonomy_functions.R")
source("part06_functions_taxonomy_functions.R")
# ----------------- filenames & options -------------------------

# set working directory 
# only needed if working outside a project
# wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv"
# setwd(wd00)

#the first is the unfiltered BLAST hits
#infnm <- "part04_blast_b009.results.01_1000_lines.txt"
#define input file names - i.e. the output you got from the blast result
#the first is the unfiltered BLAST hits
inputfilenm1="part04_blast_blibnumber.results.01.txt"
#inputfilenm1="part04_blast_b009.results.01.txt"
# the secomnd file is the prefiltered BLAST hits from which the more untrusted species have been removed
inputfilenm2="part05_blast_blibnumber.results.02.txt"
#inputfilenm2="part05_blast_b009.results.02.txt"

#define output file names 
outputfilenm1="part06_my_classified_otus_blibnumber.01.unfilt_BLAST_results.txt"
outputfilenm2="part06_my_classified_otus_blibnumber.02.filt_BLAST_results.txt"

# outputfilenm1="part06_my_classified_otus_b009.01.unfilt_BLAST_results.txt"
# outputfilenm2="part06_my_classified_otus_b009.02.filt_BLAST_results.txt"

#bind file names in a data frame
df_iofn <- as.data.frame(cbind(
            c(1,2),
            c(inputfilenm1,inputfilenm2),
            c(outputfilenm1,outputfilenm2)))
colnames(df_iofn) <- c("flno",
                       "inf",
                       "ouf")
# possible problematic TaxIDs
inprob <- "part06_MergedTaxIDs.txt"

#Provide ENTREZ API key
options(ENTREZ_KEY="7ba07daba5fe26e44ea50deda6506d977a09")


# print(args[1])
# print(args[2])
# iterate over file names in data frame
for (i in seq(1:length(df_iofn$flno)))
{
  print(i)
  infnm <- df_iofn$inf[i]
  oufnm <- df_iofn$ouf[i]
#}
  #modify input file names to get output file names
  otfma <- gsub("part[0-9]+_(.*)\\.results.([0-9]+).*txt","\\1_\\2",infnm)
  
# ----------------- start processing ---------------------------

# Read the completed blast results into a table
IDtable <- read.csv(file = infnm, sep='\t', header=F, as.is=TRUE)

# Read the possible problematic TaxIDs as a table
MergedTaxIDs<-read.table(inprob, header=TRUE)

# Add column names
names(IDtable) <- c("qseqid","sseqid","pident","length",
                    "mismatch","gapopen","qstart","qend",
                    "sstart","send","evalue","bitscore",
                    "qlen","qcovs","sgi","sseq","ssciname","staxid")

# Extract only those rows where the qcovs score is 100
IDtable <- IDtable[IDtable$qcovs==100,]


# Prefilter the IDtable
IDtable <- prefilter(IDtable) # using default options

# replace IDs of possible problematic TaxIDs
IDtable <- taxid_replace(IDtable,MergedTaxIDs,printlist=T)

# Get classifications
gc <- get_classification(IDtable,sleep_interval=300,timeout_limit=8)

# Evaluate classifications
cf <- evaluate_classification(gc[[1]]) # AGR # gc[2] is the wrong taxid not classified 

classified_table <- cf$taxonon_table 
all_classifications <- cf$all_taxa_table
all_classifications_summed <- cf$all_taxa_table_summed

if (length(gc[[2]]) != 0) {
  print(paste0("Taxids not found in the classification: ", gc[2])) # AGR - Print the list of not matched taxids  
}

gc_2 <- gc[[2]]
# ----------------- save results ---------------------------


fnm_Rda <- paste("part06_class_results_",otfma,".Rda",sep="")
save(classified_table,
     all_classifications,
     all_classifications_summed,
     not_found=gc_2,
     file=fnm_Rda)


#Write the result to a table
write.table(classified_table, oufnm, sep = "\t", quote = F, row.names = F)

#end iteration over input files
}

# ----------------- NOTES ---------------------------
#
# Explanation to input
#   INPUT.blasthits is the blast-results
#   upper_margin is the margin used for suboptimal hits used for classification - e.g. a margin of 0.5 means that hits of 100% to 99.5% is used og 95% to 94.5%, if the best hit is 100% or 95% respectively.
#   lower_margin: hits down to this margin from the best hit are shown in the output as alternative possibilities, but not used for taxonomic evaluation.
#   remove: a vector of taxa to exclude from the evaluation. Could be e.g. remove = c("uncultured","environmental") to exclude hits with no precise annotation, or names of species known not to be in the study area.
#
# Explanation to output
#   the output is a list with
#   $classified_table : the table with all OTUs classified. One row per OTU
#        this table contains the estimated best classification at all taxonomic levels, based on a weighted score (of the evalue) of the hits in the upper_margin, 
#        each taxonomic level gets a score indicating the agreement on the selected classification at that level..
#        also a string of alternatives and their matches (%) this string includes hits from both upper and lower margin
#   $all_classifications: this is the table used to make the classified_table. It contains all hits above lower_magrin for all OTUs and their classifications (only upper_margin).
#   ...and the input parameters
