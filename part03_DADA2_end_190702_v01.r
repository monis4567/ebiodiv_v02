#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

# replace my  path to the R packages to your own  path for R packages
#lib_path01 <- "/groups/hologenomics/phq599/data/R_packages_for_Rv3_4"
lib_path01 <- "/groups/hologenomics/phq599/data/R_packages_for_Rv4_0_2"
Sys.setenv(R_LIBS_USER="lib_path01")
.libPaths("lib_path01")
# change the path to where the packages should be installed from # see this website: https://stackoverflow.com/questions/15170399/change-r-default-library-path-using-libpaths-in-rprofile-site-fails-to-work
.libPaths( c( lib_path01 , .libPaths() ) )
.libPaths()

require(dada2)
library(dada2)

#define present working directory
pwd <- getwd()
setwd(pwd)
main_path <- pwd

print(c)
# define path to a local copied version of sickle
#local_path_to_demultiplexed <- paste0(main_path,"/01_demultiplex_filtered")
#full_path_to_blibrary <- paste0(local_path_to_demultiplexed,"/blibrarynumber")
full_path_to_blibrary_p0 <- main_path
#Define a function for combining two or more tables, collapsing samples with similar names:  
sumSequenceTables <- function(table1, table2, ..., orderBy = "abundance") {
  # Combine passed tables into a list
  tables <- list(table1, table2)
  tables <- c(tables, list(...))
  # Validate tables
  if(!(all(sapply(tables, dada2:::is.sequence.table)))) {
    stop("At least two valid sequence tables, and no invalid objects, are expected.")
  }
  sample.names <- rownames(tables[[1]])
  for(i in seq(2, length(tables))) {
    sample.names <- c(sample.names, rownames(tables[[i]]))
  }
  seqs <- unique(c(sapply(tables, colnames), recursive=TRUE))
  sams <- unique(sample.names)
  # Make merged table
  rval <- matrix(0L, nrow=length(sams), ncol=length(seqs))
  rownames(rval) <- sams
  colnames(rval) <- seqs
  for(tab in tables) {
    rval[rownames(tab), colnames(tab)] <- rval[rownames(tab), colnames(tab)] + tab
  }
  # Order columns
  if(!is.null(orderBy)) {
    if(orderBy == "abundance") {
      rval <- rval[,order(colSums(rval), decreasing=TRUE),drop=FALSE]
    } else if(orderBy == "nsamples") {
      rval <- rval[,order(colSums(rval>0), decreasing=TRUE),drop=FALSE]
    }
  }
  rval
}

print(full_path_to_blibrary_p0)
# define the main path to your library 1
#YOUR_LIB_1 <- "/groups/hologenomics/phq599/data/AMRH_MBIBAL_1-demultiplexed"
YOUR_LIB_1 <- full_path_to_blibrary_p0
#define paths to your libraries
path_AS_RDS_1 <- paste(YOUR_LIB_1,"/seqtab_AS_RDS", sep="")
path_seqtab.nochim_AS_RDS_1 <- paste(YOUR_LIB_1,"/seqtab.nochim_AS_RDS", sep="")
path_seqtab_SS_RDS_1 <- paste(YOUR_LIB_1,"/seqtab_SS_RDS", sep="")
path_seqtab.nochim_SS_RDS_1 <- paste(YOUR_LIB_1,"/seqtab.nochim_SS_RDS", sep="")

###Lib 1
stAS <- file.path(path_AS_RDS_1)
stnsAS <- file.path(path_seqtab.nochim_AS_RDS_1)
stSS <- file.path(path_seqtab_SS_RDS_1)
stnsSS <- file.path(path_seqtab.nochim_SS_RDS_1)
seqtab.nochim_AS <- readRDS(stnsAS)
seqtab.nochim_SS <- readRDS(stnsSS)
seqtab_AS <- readRDS(stAS)
seqtab_SS <- readRDS(stSS)
sumtable <- sumSequenceTables(seqtab_SS,seqtab_AS) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
nochim_sumtable <- sumSequenceTables(seqtab.nochim_SS,seqtab.nochim_AS)

# define the main path to your library 2
#YOUR_LIB_2 <- "/groups/hologenomics/phq599/data/AMRH_MBIBBL_1-demultiplexed"
YOUR_LIB_2 <- full_path_to_blibrary_p0
#define paths to your libraries
path_AS_RDS_2 <- paste(YOUR_LIB_2,"/seqtab_AS_RDS", sep="")
path_seqtab.nochim_AS_RDS_2 <- paste(YOUR_LIB_2,"/seqtab.nochim_AS_RDS", sep="")
path_seqtab_SS_RDS_2 <- paste(YOUR_LIB_2,"/seqtab_SS_RDS", sep="")
path_seqtab.nochim_SS_RDS_2 <- paste(YOUR_LIB_2,"/seqtab.nochim_SS_RDS", sep="")

####Lib 2 - uncomment this section if you have 2 replicate metabarcoded NGS libraries you want to merge and compare, and use section 01 below
#stAS2 <- file.path(path_AS_RDS_2)
#stnsAS2 <- file.path(path_seqtab.nochim_AS_RDS_2)
#stSS2 <- file.path(path_seqtab_SS_RDS_2)
#stnsSS2 <- file.path(path_seqtab.nochim_SS_RDS_2)
#seqtab.nochim_AS2 <- readRDS(stnsAS2)
#seqtab.nochim_SS2 <- readRDS(stnsSS2)
#seqtab_AS2 <- readRDS(stAS2)
#seqtab_SS2 <- readRDS(stSS2)
#sumtable2 <- sumSequenceTables(seqtab_SS2,seqtab_AS2) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable2 <- sumSequenceTables(seqtab.nochim_SS2,seqtab.nochim_AS2)

# define the main path to your library 3
#YOUR_LIB_3 <- "/groups/hologenomics/phq599/data/AMRH_MBIBCL_1-demultiplexed"
YOUR_LIB_3 <- full_path_to_blibrary_p0
#define paths to your libraries
path_AS_RDS_3 <- paste(YOUR_LIB_3,"/seqtab_AS_RDS", sep="")
path_seqtab.nochim_AS_RDS_3 <- paste(YOUR_LIB_3,"/seqtab.nochim_AS_RDS", sep="")
path_seqtab_SS_RDS_3 <- paste(YOUR_LIB_3,"/seqtab_SS_RDS", sep="")
path_seqtab.nochim_SS_RDS_3 <- paste(YOUR_LIB_3,"/seqtab.nochim_SS_RDS", sep="")

####Lib 3 - uncomment this section if you have 3 replicate metabarcoded NGS libraries you want to merge and compare, and use section 01 below

#stAS3 <- file.path(path_AS_RDS_3)
#stnsAS3 <- file.path(path_seqtab.nochim_AS_RDS_3)
#stSS3 <- file.path(path_seqtab_SS_RDS_3)
#stnsSS3 <- file.path(path_seqtab.nochim_SS_RDS_3)
#seqtab.nochim_AS3 <- readRDS(stnsAS3)
#seqtab.nochim_SS3 <- readRDS(stnsSS3)
#seqtab_AS3 <- readRDS(stAS3)
#seqtab_SS3 <- readRDS(stSS3)
#sumtable3 <- sumSequenceTables(seqtab_SS3,seqtab_AS3) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable3 <- sumSequenceTables(seqtab.nochim_SS3,seqtab.nochim_AS3)

# define the main path to your library 4
#YOUR_LIB_4 <- "/groups/hologenomics/phq599/data/AMRH_MBIBDL_1-demultiplexed"
YOUR_LIB_4 <- full_path_to_blibrary_p0
#define paths to your libraries
path_AS_RDS_4 <- paste(YOUR_LIB_4,"/seqtab_AS_RDS", sep="")
path_seqtab.nochim_AS_RDS_4 <- paste(YOUR_LIB_4,"/seqtab.nochim_AS_RDS", sep="")
path_seqtab_SS_RDS_4 <- paste(YOUR_LIB_4,"/seqtab_SS_RDS", sep="")
path_seqtab.nochim_SS_RDS_4 <- paste(YOUR_LIB_4,"/seqtab.nochim_SS_RDS", sep="")

####Lib 4 - uncomment this section if you have 4 replicate metabarcoded NGS libraries you want to merge and compare, and use section 01 below
#stAS4 <- file.path(path_AS_RDS_4)
#stnsAS4 <- file.path(path_seqtab.nochim_AS_RDS_4)
#stSS4 <- file.path(path_seqtab_SS_RDS_4)
#stnsSS4 <- file.path(path_seqtab.nochim_SS_RDS_4)
#seqtab.nochim_AS4 <- readRDS(stnsAS4)
#seqtab.nochim_SS4 <- readRDS(stnsSS4)
#seqtab_AS4 <- readRDS(stAS4)
#seqtab_SS4 <- readRDS(stSS4)
#sumtable4 <- sumSequenceTables(seqtab_SS4,seqtab_AS4) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable4 <- sumSequenceTables(seqtab.nochim_SS4,seqtab.nochim_AS4)

###Merge Libraries - comment out this section 01 if you do NOT have multiple libraries representing replicate libraries
# if you only have one single library then comment out setcion 01 here below and instead use section 02
#### start section 01
#sumtable_1_2 <- sumSequenceTables(sumtable,sumtable2) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable_1_2 <- sumSequenceTables(nochim_sumtable,nochim_sumtable2)
#sumtable_3_4 <- sumSequenceTables(sumtable3,sumtable4) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable_3_4 <- sumSequenceTables(nochim_sumtable3,nochim_sumtable4)
#sumtable_all <- sumSequenceTables(sumtable_1_2,sumtable_3_4) # den her kommando kan merge to tabeller. sammen navn og/eller samme sekvens merges.
#nochim_sumtable_all <- sumSequenceTables(nochim_sumtable_1_2,nochim_sumtable_3_4)
#### end section 01 

# use section 02 here below instead of section 01 if you only have one single library
# If you have several libraries, then do NOT use section 02 here below, but instead use section 01 above
#### start section 02
sumtable_all <- sumtable
nochim_sumtable_all <- nochim_sumtable
#### end section 02

stBoth <- file.path("seqtab_Both")
stnsBoth <- file.path("seqtab.nochim_Both")
saveRDS(sumtable_all,stBoth)
saveRDS(nochim_sumtable_all,stnsBoth)

#Transpose table, assign names, extract sequences and saving table, for further processing:
trans_nochim_sumtable <- as.data.frame(t(nochim_sumtable_all))
#Get DNA sequences
sequences <- row.names(trans_nochim_sumtable)
#Assign new rownames
row.names(trans_nochim_sumtable) <- paste0("seq",seq.int(nrow(trans_nochim_sumtable)))
tbname <- file.path("DADA2_nochim.table")
{write.table(trans_nochim_sumtable,tbname,sep="\t",col.names = NA, quote=FALSE)}
#Extract OTUs (sequences)
sinkname <- file.path("DADA2_nochim.otus")
{
  sink(sinkname)
  for (seqX in seq.int(nrow(trans_nochim_sumtable))) {
    header <- paste0(">","seq",seqX,"\n")
    cat(header)
    seqq <- paste0(sequences[seqX],"\n")
    cat(seqq)
  }
  sink()
}

#Define function to extract sequences sample-wise
extrSamDADA2 <- function(my_table) {
  out_path <- file.path("DADA2_extracted_samples_nochim")
  if(!file_test("-d", out_path)) dir.create(out_path)
  for (sampleX in seq(1:dim(my_table)[1])){
    sinkname <- file.path(out_path, paste0(rownames(my_table)[sampleX],".fas"))
    {
      sink(sinkname)
      for (seqX in seq(1:dim(my_table)[2])) {
        if (my_table[sampleX,seqX] > 0) {
          header <- paste0(">",rownames(my_table)[sampleX],";size=",my_table[sampleX,seqX],";","\n")
          cat(header)
          seqq <- paste0(colnames(my_table)[seqX],"\n")
          cat(seqq)
        }
      }
      sink()
    }
  }
}

#Extract samplewise sequences from the non-chimera table using the above function:
extrSamDADA2(nochim_sumtable_all)



#Transpose table, assign names, extract sequences and saving table, for further processing:
trans_raw_sumtable <- as.data.frame(t(sumtable_all))
#Get DNA sequences
sequences <- row.names(trans_raw_sumtable)
#Assign new rownames
row.names(trans_raw_sumtable) <- paste0("seq",seq.int(nrow(trans_raw_sumtable)))
tbname <- file.path("DADA2_raw.table")
{write.table(trans_raw_sumtable,tbname,sep="\t",col.names = NA, quote=FALSE)}
#Extract OTUs (sequences)
sinkname <- file.path("DADA2_raw.otus")
{
  sink(sinkname)
  for (seqX in seq.int(nrow(trans_raw_sumtable))) {
    header <- paste0(">","seq",seqX,"\n")
    cat(header)
    seqq <- paste0(sequences[seqX],"\n")
    cat(seqq)
  }
  sink()
}

#Define function to extract sequences sample-wise
extrSamDADA2 <- function(my_table) {
  out_path <- file.path("DADA2_extracted_samples_raw")
  if(!file_test("-d", out_path)) dir.create(out_path)
  for (sampleX in seq(1:dim(my_table)[1])){
    sinkname <- file.path(out_path, paste0(rownames(my_table)[sampleX],".fas"))
    {
      sink(sinkname)
      for (seqX in seq(1:dim(my_table)[2])) {
        if (my_table[sampleX,seqX] > 0) {
          header <- paste0(">",rownames(my_table)[sampleX],";size=",my_table[sampleX,seqX],";","\n")
          cat(header)
          seqq <- paste0(colnames(my_table)[seqX],"\n")
          cat(seqq)
        }
      }
      sink()
    }
  }
}

#Extract samplewise sequences from the non-chimera table using the above function:
extrSamDADA2(sumtable_all)


#