#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#################################################################################
#
# Code developed for analysis of metabarcode NGS data
# obtained with NGS
#
# code prepared by  Steen Wilhelm Knudsen 
# in Oct-2021 at the Zoological Museum of Copenhagen

# With the aim of producing stacked bar plots as
# what is presented in these studies:
# Fig. 4 , in Thomsen et al. 2016. PlosOne.   ( https://doi.org/10.1371/journal.pone.0165252)
# Fig. 2 in Li et al., 2019. (DOI: 10.1111/1365-2664.13352.)
# Fig. 4. in Guenther et al. 2018. Sci Reports. (2018) 8:14822 (DOI:10.1038/s41598-018-32917-x.)
#remove everything in the working environment, without a warning!!
rm(list=ls())
#set working directory
#setwd(my_wd)
# replace my library path to your own library path
# lib_path01 <- "/groups/hologenomics/phq599/data/R_packages_for_Rv4_0_2"
# Sys.setenv(R_LIBS_USER="lib_path01")
# .libPaths("lib_path01")
# # change the path to where the packages should be installed from # see this website: https://stackoverflow.com/questions/15170399/change-r-default-library-path-using-libpaths-in-rprofile-site-fails-to-work
# .libPaths( c( lib_path01 , .libPaths() ) )
# .libPaths()

# define the input file names
# first read in the renamed 'DADA2_nochim.table'
#that has been renamed to : 'part03_DADA2_nochim.table.JMS_FL.txt'
#read unfiltered nochim.table (no local species list filtration)
# define the input file names
# first read in the renamed 'DADA2_nochim.table' 
#that has been renamed to : 'part03_DADA2_nochim.table.JMS_FL.txt'
 libnm <-"blibnumber"
 # libnm <-"b009"
#wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv"
# wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv"
# setwd(wd00)
inp_fn1 <- paste("part03_DADA2_nochim.table.",libnm,".txt",sep="")

#inp_fn2 <- "part06_my_classified_otus_JMSFL.01.unfilt_BLAST_results.txt"
inp_fn2 <- paste("part06_my_classified_otus_",libnm,".01.unfilt_BLAST_results.txt",sep="")
#inp_fn3 <- "part06_my_classified_otus_JMSFL.02.filt_BLAST_results.txt"
inp_fn3 <- paste("part06_my_classified_otus_",libnm,".02.filt_BLAST_results.txt",sep="")
# 

inp_fn4 <- "part07_list_of_blasthits_evaluations.txt"
#text file with list of mock species
inp_fn5 <- "part05_lst_species_in_PCmock.txt"
# inp_fn1 <- "../ufiltreret/part03_output_DADA2_nochim.table.JMS_MFE.txt"
# #red unfiltered otus  (no local species list filtration)
# inp_fn2 <- "../ufiltreret/part05_output_my_classified_otus_JMS_MFE.txt"
# #read filtered otus (with local species filtration)
# inp_fn3 <- "my_classified_otus.txt"

###Get packages
#install.packages("dplyr")
#install.packages("cowplot")

#install.packages("ggpubr")
if(!require(ggpubr)){
  install.packages("ggpubr")
  library(ggpubr)
}
library(ggpubr)

# if(!require(randomcoloR)){
#   install.packages("randomcoloR")
#   library(randomcoloR)
# }
#install.packages("ggplot2")
#install.packages("reshape2")
library(ggplot2)
library(reshape2)
library(ggpubr)
#library(randomcoloR)
#turn .table file with columns seperated by tab into table
# set 'fill=T' to TRUE to make sure that tables with irregular number of columns are read in as well
tbl_nochim01 <- read.table(file=inp_fn1,sep='\t',header=T, fill=T)
#read in list of mock species
tbl_mockspc <- read.table(file=inp_fn5,sep='\t',header=F, fill=T)
colnames(tbl_mockspc) <- c("genus_species")
tbl_mockspc$genus <- gsub("^(.*) (.*)$","\\1",tbl_mockspc$genus_species)
tbl_mockspc$species <- gsub("^(.*) (.*)$","\\2",tbl_mockspc$genus_species)
#read in the result from the taxonomyB_R code
# set 'fill=T' to TRUE to make sure that tables with irregular number of columns are read in as well
df_blast_unfilt_01 <- read.csv(file=inp_fn2,sep='\t',header=T, 
                                   stringsAsFactors = F, fill=T, dec=".")
df_blast_filt_01 <- read.table(file=inp_fn3,sep='\t',header=T, stringsAsFactors = F, fill=T)
#you will need to read in the blast hit results with 'stringsAsFactors = F' to be able to
# replace the NA's later on

# see the first 4 header lines
#head(df_blast_unfilt_01,3)
#see what the columns are named
#colnames(df_blast_unfilt_01)
#assign some of the columns to objects
blast_unfilt_seqID <- df_blast_unfilt_01$qseqid
blast_unfilt_class <- df_blast_unfilt_01[,11] #class
blast_unfilt_order <- df_blast_unfilt_01[,12] #order
blast_unfilt_fam <- df_blast_unfilt_01[,13] #family
blast_unfilt_genus <- df_blast_unfilt_01[,14] #genus
blast_unfilt_genus_species <- df_blast_unfilt_01[,15] #genus_species

blast_filt_seqID <- df_blast_filt_01$qseqid
blast_filt_class <- df_blast_filt_01[,11] #class
blast_filt_order <- df_blast_filt_01[,12] #order
blast_filt_fam <- df_blast_filt_01[,13] #family
blast_filt_genus <- df_blast_filt_01[,14] #genus
blast_filt_genus_species <- df_blast_filt_01[,15] #genus_species

#convert data frame from a "wide" format to a "long" format
df_nochim01_melt <- melt(tbl_nochim01, id = c("X"))

#change the column names
colnames(df_nochim01_melt)[1] <- c("SeqNo")
colnames(df_nochim01_melt)[2] <- c("smpl.loc")
colnames(df_nochim01_melt)[3] <- c("seq.rd.cnt")
#head(df_nochim01_melt,4)
#match between data frames
df_nochim01_melt$blast_unfilt_class <- df_blast_unfilt_01[,11][match(df_nochim01_melt$SeqNo,df_blast_unfilt_01$qseqid)]
df_nochim01_melt$blast_unfilt_order <- df_blast_unfilt_01[,12][match(df_nochim01_melt$SeqNo,df_blast_unfilt_01$qseqid)]
df_nochim01_melt$blast_unfilt_fam <- df_blast_unfilt_01[,13][match(df_nochim01_melt$SeqNo,df_blast_unfilt_01$qseqid)]
df_nochim01_melt$blast_unfilt_genus <- df_blast_unfilt_01[,14][match(df_nochim01_melt$SeqNo,df_blast_unfilt_01$qseqid)]
df_nochim01_melt$blast_unfilt_genus_species <- df_blast_unfilt_01[,15][match(df_nochim01_melt$SeqNo,df_blast_unfilt_01$qseqid)]
#match between data frames
df_nochim01_melt$blast_filt_class <- df_blast_filt_01[,11][match(df_nochim01_melt$SeqNo,df_blast_filt_01$qseqid)]
df_nochim01_melt$blast_filt_order <- df_blast_filt_01[,12][match(df_nochim01_melt$SeqNo,df_blast_filt_01$qseqid)]
df_nochim01_melt$blast_filt_fam <- df_blast_filt_01[,13][match(df_nochim01_melt$SeqNo,df_blast_filt_01$qseqid)]
df_nochim01_melt$blast_filt_genus <- df_blast_filt_01[,14][match(df_nochim01_melt$SeqNo,df_blast_filt_01$qseqid)]
df_nochim01_melt$blast_filt_genus_species <- df_blast_filt_01[,15][match(df_nochim01_melt$SeqNo,df_blast_filt_01$qseqid)]

# Replace the NA's with 'none', you will have to read in your blast hit tables with 'stringsAsFactors = FALSE' flag
# to be allowed to make this change
df_nochim01_melt[is.na(df_nochim01_melt)] <- "none"
#make the counts a numeric value
df_nochim01_melt$seq.rd.cnt <- as.factor(df_nochim01_melt$seq.rd.cnt)
#make a column with full taxonomic path for unfiltered hits
df_nochim01_melt$blast_unfilt_class_ord_fam_gen_spc <-
  paste(df_nochim01_melt$blast_unfilt_class,
        df_nochim01_melt$blast_unfilt_order,
        df_nochim01_melt$blast_unfilt_fam,
        df_nochim01_melt$blast_unfilt_genus_species,
        sep="_")
#sort(unique(df_nochim01_melt$blast_unfilt_class_ord_fam_gen_spc))
#make a column with full taxonomic path for unfiltered hits
df_nochim01_melt$blast_filt_class_ord_fam_gen_spc <-
  paste(df_nochim01_melt$blast_filt_class,
        df_nochim01_melt$blast_filt_order,
        df_nochim01_melt$blast_filt_fam,
        df_nochim01_melt$blast_filt_genus_species,
        sep="_")
#see the different taxonomical hierachichal elements sorted alphabetically
#sort(unique(df_nochim01_melt$blast_filt_class_ord_fam_gen_spc))
#get count of unique elements for class for filtered BLAST hits
ll05 <-length(unique(df_nochim01_melt$blast_filt_class))
ll06 <-length(unique(df_nochim01_melt$blast_filt_fam))
#get count of unique elements for class for filtered BLAST hits
ll07 <-length(unique(df_nochim01_melt$blast_unfilt_class))
ll08 <-length(unique(df_nochim01_melt$blast_unfilt_fam))



#https://chartio.com/resources/tutorials/how-to-sort-a-data-frame-by-multiple-columns-in-r/
#reorder the data frame by class, then by fam then by genus and species
df_ncm02 <- df_nochim01_melt[
  with(df_nochim01_melt, order(blast_unfilt_class,
                               blast_unfilt_order,
                               blast_unfilt_fam,
                               blast_unfilt_genus_species)), ]

#unique(df_ncm02$blast_unfilt_class)

#subset data frame if observations match or does not match
df_ncm03_unfilt_tspc <- df_ncm02[ which(df_ncm02$blast_unfilt_class=="Actinopteri" 
                                        | df_ncm02$blast_unfilt_class=="Mammalia"
                                        | df_ncm02$blast_unfilt_class=="Hyperoartia"
                                        | df_ncm02$blast_unfilt_class=="Chondrichthyes"), ]
#uncomment the next two lines if you want to check the unique elements in the new data frames
#unique(df_ncm02$blast_unfilt_class)
#unique(df_ncm03_unfilt_tspc$blast_unfilt_class)
df_ncm03_unfilt_not_tspc <- df_ncm02[ which(!df_ncm02$blast_unfilt_class=="Actinopteri"
                                            & !df_ncm02$blast_unfilt_class=="Mammalia"
                                            & !df_ncm02$blast_unfilt_class=="Hyperoartia"
                                            & !df_ncm02$blast_unfilt_class=="Chondrichthyes"), ]
#uncomment the next two lines if you want to check the unique elements in the new data frames
#unique(df_ncm02$blast_unfilt_class)
#unique(df_ncm03_unfilt_not_tspc$blast_unfilt_class)
df_ncm03_filt_tspc <- df_ncm02[ which(df_ncm02$blast_filt_class=="Actinopteri"
                                      | df_ncm02$blast_filt_class=="Mammalia"
                                      | df_ncm02$blast_filt_class=="Hyperoartia"
                                      | df_ncm02$blast_filt_class=="Chondrichthyes"), ]
#uncomment the next two lines if you want to check the unique elements in the new data frames
#unique(df_ncm02$blast_filt_class)
#unique(df_ncm03_filt_tspc$blast_filt_class)
df_ncm03_filt_not_tspc <- df_ncm02[ which(!df_ncm02$blast_filt_class=="Actinopteri" 
                                    & !df_ncm02$blast_filt_class=="Mammalia"
                                    & !df_ncm02$blast_filt_class=="Hyperoartia"
                                    & !df_ncm02$blast_filt_class=="Chondrichthyes"), ]
#uncomment the next two lines if you want to check the unique elements in the new data frames
#unique(df_ncm02$blast_filt_class)
#unique(df_ncm03_filt_not_tspc$blast_filt_class)
#get count of unique elements for class for unfiltered BLAST hits
ll05 <- length(unique(df_ncm03_unfilt_not_tspc$blast_unfilt_fam))
ll06 <- length(unique(df_ncm03_unfilt_tspc$blast_unfilt_fam))
#get count of unique elements for class for filtered BLAST hits
ll07 <- length(unique(df_ncm03_filt_not_tspc$blast_filt_fam))
ll08 <- length(unique(df_ncm03_filt_tspc$blast_filt_fam))


#https://stackoverflow.com/questions/15282580/how-to-generate-a-number-of-most-distinctive-colors-in-r
#library(randomcoloR)
#make a color palette for the unique elements
#pal01 <- distinctColorPalette(ll01)
#see the colors in a pie
#pie(rep(1,ll01), col=sample(pal01, ll01))
#assign color to coloumn in df matching the columns the colors were based on
#e01_df$cg01 <- c(pal01)[e01_df$a12]
#install.packages("viridis")
library(viridis)
#make a colour range on the family matches in unfiltered BLAST elements
pal05<-viridis_pal(option = "A")(ll05) # not Actinop unfiltered
pal06<-viridis_pal(option = "D")(ll06) # Actinop unfiltered
#make a colour range on the filtered BLAST elements
pal07<-viridis_pal(option = "A")(ll07) # not Actinop filtered
pal08<-viridis_pal(option = "D")(ll08) # Actinop filtered
#see the colors in a pie
#pie(rep(1,ll06), col=sample(pal06, ll06)) #based on unfiltered BLAST, , Actinop
#pie(rep(1,ll08), col=sample(pal08, ll08)) #based on filtered BLAST, Actinop
#see colours in pie
#pie(rep(1,ll05), col=sample(pal05, ll05)) #based on unfiltered BLAST not Actinop
#pie(rep(1,ll07), col=sample(pal07, ll07)) #based on filtered BLAST not Actinop
# make data frames with colours matching family names
df_col_unfilt_not_tspc_fam01 <-as.data.frame(cbind(unique(df_ncm03_unfilt_not_tspc$blast_unfilt_fam),c(pal05)))
df_col_unfilt_tspc_fam01 <-as.data.frame(cbind(unique(df_ncm03_unfilt_tspc$blast_unfilt_fam),c(pal06)))
#bind the two dataframes together by row
df_col_unfilt_fam02<-rbind(df_col_unfilt_tspc_fam01,df_col_unfilt_not_tspc_fam01)
# make data frames with colours matching family names
df_col_filt_not_tspc_fam01 <-as.data.frame(cbind(unique(df_ncm03_filt_not_tspc$blast_filt_fam),c(pal07)))
df_col_filt_tspc_fam01 <-as.data.frame(cbind(unique(df_ncm03_filt_tspc$blast_filt_fam),c(pal08)))
#bind the two dataframes together by row
df_col_filt_fam02<-rbind(df_col_filt_tspc_fam01,df_col_filt_not_tspc_fam01)
#assign color to coloumn in df matching the columns the colors were based on
df_ncm02$col_filt_fam <- df_col_filt_fam02$V2[match(df_ncm02$blast_filt_fam, df_col_filt_fam02$V1)]
df_ncm02$col_unfilt_fam <- df_col_unfilt_fam02$V2[match(df_ncm02$blast_unfilt_fam, df_col_unfilt_fam02$V1)]
# make the hex color codes characters to allow them to eb interpreted as hex colors
df_ncm02$col_filt_fam <- as.character(df_ncm02$col_filt_fam)
df_ncm02$col_unfilt_fam <- as.character(df_ncm02$col_unfilt_fam)
# see them in a pie
c <- as.character(df_col_filt_fam02$V2)
l <- length(df_col_filt_fam02$V2)
#pie(rep(1,l), col=sample(c, l))
# see them in a pie
c <- as.character(df_col_unfilt_fam02$V2)
l <- length(df_col_unfilt_fam02$V2)
#pie(rep(1,l), col=sample(c, l))
#count genus-species in the unfiltered list
csg_unf1_df <- as.data.frame(table(df_ncm02$blast_unfilt_genus_species))
#count genus-species in the filtered list
csg_f1_df <- as.data.frame(table(df_ncm02$blast_filt_genus_species))


#___________________________________________________________________________________
# make a data frame for unfiltered colors
#___________________________________________________________________________________
# make a data frame with unique genus-species from the unfiltered BLAST hits
# to use for preparing a color range that can be matched back to the main data frame
# afterwards
#colnames(df_ncm02)
#define the columns to keep
keeps <- c( "blast_unfilt_class_ord_fam_gen_spc",
            "blast_unfilt_fam",
            "blast_unfilt_genus",
            "blast_unfilt_genus_species",
            "col_unfilt_fam")
#keep only selected columns
df_col_unf_fam01 <- df_ncm02[keeps]
#remove rows that are duplicated for a column
df_col_unf_fam02<- df_col_unf_fam01[!duplicated(df_col_unf_fam01$blast_unfilt_genus_species), ]
#remove rows with NAs : https://stackoverflow.com/questions/4862178/remove-rows-with-all-or-some-nas-missing-values-in-data-frame
df_col_unf_fam03 <- df_col_unf_fam02[complete.cases(df_col_unf_fam02), ]
#df_col_unf_fam03 <- df_col_unf_fam02

#head(df_col_unf_fam03, 5)
#https://chartio.com/resources/tutorials/how-to-sort-a-data-frame-by-multiple-columns-in-r/
#reorder the data frame by class, then by fam then by genus and species
df_col_unf_fam04 <- df_col_unf_fam03[
  with(df_col_unf_fam03, order(blast_unfilt_class_ord_fam_gen_spc,
                               blast_unfilt_fam,
                               blast_unfilt_genus,
                               blast_unfilt_genus_species)),]
#https://stackoverflow.com/questions/30491497/running-count-within-groups-in-a-dataframe
#make count per class
library(dplyr)
tbl_col_unf_fam04 <-df_col_unf_fam04 %>%
  group_by(blast_unfilt_fam) %>%
  mutate(count = seq(n()))
#make the tibble a data frame instead
df_col_unf_fam05 <- as.data.frame(tbl_col_unf_fam04)
#get the max count per class
tbl_col_unf_fam05 <-df_col_unf_fam04 %>%
  group_by(blast_unfilt_fam) %>%
  mutate(max = max(n()))
#make the tibble a data frame instead
df_col_unf_fam06 <- as.data.frame(tbl_col_unf_fam05)
#match back to the counted data frame
df_col_unf_fam04$count <- df_col_unf_fam05$count[match(df_col_unf_fam05$blast_unfilt_genus_species,df_col_unf_fam04$blast_unfilt_genus_species)]
#match back to the max values data frame
df_col_unf_fam04$max <- df_col_unf_fam06$max[match(df_col_unf_fam06$blast_unfilt_fam,df_col_unf_fam04$blast_unfilt_fam)]
#get fractions for colors
df_col_unf_fam04$frq_col <- (df_col_unf_fam04$count/df_col_unf_fam04$max)
# copy the data frame
df_col_unf_fam07 <- df_col_unf_fam04

#make an empty list : https://stackoverflow.com/questions/55445629/appending-a-list-in-a-loop-r
lst_col <- list()
#iterate over elements and append to the empty list
for (i in df_col_unf_fam07$blast_unfilt_class_ord_fam_gen_spc){
    hc<-df_col_unf_fam07$col_unfilt_fam[match(i,df_col_unf_fam07$blast_unfilt_class_ord_fam_gen_spc)]
  f <- colorRamp(c("white", hc))
  zv<-df_col_unf_fam07$frq_col[match(i,df_col_unf_fam07$blast_unfilt_class_ord_fam_gen_spc)]
  hexcol03 <- (colors <- rgb(f(zv)/255))
  lst_col<- append(lst_col, list(hexcol03))
}
#make the list a matrix, and turn them in to characters
hcol_cl3 <- as.character(as.matrix(lst_col))
#hcol_cl3 <- as.character(as.matrix(lst_col2))

#length(hcol_cl3)
#length(df_col_unf_fam07$blast_unfilt_genus_species)
#append them back to the dataframe
df_col_unf_fam07$col_unfilt_gen_spc <- hcol_cl3
#use a different name for colors to test
colors<-df_col_unf_fam07$col_unfilt_gen_spc
## Check that it works
# image(seq_along(df_col_unf_fam07$col_unfilt_gen_spc), 1, as.matrix(seq_along(df_col_unf_fam07$col_unfilt_gen_spc)), col=colors,
#       axes=FALSE, xlab="", ylab="")
#___________________________________________________________________________________


#___________________________________________________________________________________
# make a data frame for filtered colors
#___________________________________________________________________________________

# make a data frame with unique genus-species from the filtered BLAST hits
# to use for preparing a color range that can be matched back to the main data frame
# afterwards
#define the columns to keep
keeps <- c("blast_filt_class_ord_fam_gen_spc" ,
           "blast_filt_fam",
           "blast_filt_genus",
           "blast_filt_genus_species",
           "col_filt_fam")
#keep only selected columns
df_col_f_fam01 <- df_ncm02[keeps]
#remove rows that are duplicated for a column
df_col_f_fam02<- df_col_f_fam01[!duplicated(df_col_f_fam01$blast_filt_genus_species), ]
#remove rows with NAs : https://stackoverflow.com/questions/4862178/remove-rows-with-all-or-some-nas-missing-values-in-data-frame
df_col_f_fam03 <- df_col_f_fam02[complete.cases(df_col_f_fam02), ]
df_col_f_fam02 <- df_col_f_fam03

df_ncm03 <- df_ncm02
# head(df_col_f_fam03, 5)
#https://chartio.com/resources/tutorials/how-to-sort-a-data-frame-by-multiple-columns-in-r/
#reorder the data frame by class, then by fam then by genus and species
df_col_f_fam04 <- df_col_f_fam03[
  with(df_col_f_fam03, order(blast_filt_class_ord_fam_gen_spc,
                             blast_filt_fam,
                             blast_filt_genus,
                             blast_filt_genus_species)),]
#https://stackoverflow.com/questions/30491497/running-count-within-groups-in-a-dataframe
#make count per class
library(dplyr)
tbl_col_f_fam04 <-df_col_f_fam04 %>%
  group_by(blast_filt_fam) %>%
  mutate(count = seq(n()))
#make the tibble a data frame instead
df_col_f_fam05 <- as.data.frame(tbl_col_f_fam04)
#get the max count per class
tbl_col_f_fam05 <-df_col_f_fam04 %>%
  group_by(blast_filt_fam) %>%
  mutate(max = max(n()))
#make the tibble a data frame instead
df_col_f_fam06 <- as.data.frame(tbl_col_f_fam05)

#match back to the counted data frame
df_col_f_fam04$count <- df_col_f_fam05$count[match(df_col_f_fam05$blast_filt_genus_species,df_col_f_fam04$blast_filt_genus_species)]
#match back to the max values data frame
df_col_f_fam04$max <- df_col_f_fam06$max[match(df_col_f_fam06$blast_filt_fam,df_col_f_fam04$blast_filt_fam)]
#get fractions for colors
df_col_f_fam04$frq_col <- (df_col_f_fam04$count/df_col_f_fam04$max)
# copy the data frame
df_col_f_fam07 <- df_col_f_fam04

#make an empty list : https://stackoverflow.com/questions/55445629/appending-a-list-in-a-loop-r
lst_col <- list()
#iterate over elements and append to the empty list
for (i in df_col_f_fam07$blast_filt_class_ord_fam_gen_spc){
  hc<-df_col_f_fam07$col_filt_fam[match(i,df_col_f_fam07$blast_filt_class_ord_fam_gen_spc)]
  f <- colorRamp(c("white", hc))
  zv<-df_col_f_fam07$frq_col[match(i,df_col_f_fam07$blast_filt_class_ord_fam_gen_spc)]
  hexcol03 <- (colors <- rgb(f(zv)/255))
  #listtmp = hexcol03[, lfg]
  lst_col<- append(lst_col, list(hexcol03))
}
#make the list a matrix, and turn them in to characters
hcol_cl3 <- as.character(as.matrix(lst_col))
#append them back to the dataframe
df_col_f_fam07$col_filt_gen_spc <- hcol_cl3
#use a different name for colors to test
colors<-df_col_f_fam07$col_filt_gen_spc
## Check that it works
# image(seq_along(df_col_f_fam07$col_filt_gen_spc), 1, as.matrix(seq_along(df_col_f_fam07$col_filt_gen_spc)), col=colors,
#       axes=FALSE, xlab="", ylab="")

#_______________________________________________________________________________
#tbl_mockspc$genusspecies
#make an empty list : https://stackoverflow.com/questions/55445629/appending-a-list-in-a-loop-r
#count the number of mock species
lcm <- length(tbl_mockspc$genus_species)
lbugs <- length(unique(df_ncm03$blast_unfilt_genus_species))

#tbl_mockspc$genus
#tbl_mockspc$genusspecies %in% df_ncm03$blast_unfilt_genus_species
#get themock genera present in the unfiltered blast results
#and return the species found in the unfiltered blast results
lst_unfbgenspc_mck <- df_ncm03$blast_unfilt_genus_species[match(tbl_mockspc$genus[tbl_mockspc$genus %in% df_ncm03$blast_unfilt_genus],df_ncm03$blast_unfilt_genus)]

lst_fbgenspc_mck<- df_ncm03$blast_filt_genus_species[match(tbl_mockspc$genus[tbl_mockspc$genus %in% df_ncm03$blast_unfilt_genus],df_ncm03$blast_unfilt_genus)]

lst_mspf <-  unique(c(lst_unfbgenspc_mck,lst_fbgenspc_mck))
# make a data frame to hold colors for the mock species in the 
# unfiltered blast results
df_cfsmsp01 <- as.data.frame(cbind(lst_mspf, NA))
#change the columns names
colnames(df_cfsmsp01) <- c("mock_genspc","frm")
# count the number of species in this datafram
lcm<- length(df_cfsmsp01$mock_genspc)
#iterate of elements in list of numbers that equals the number
# of mock species, and add a fraction to the empty column
for (j in (seq(1:lcm))){
frm <- seq(1:lcm)[j]*1/lcm
df_cfsmsp01$frm[j] <- frm
}

#make an empty column to add to
df_cfsmsp01$colfm <- NA
#iterate over elements and append to the empty list
for (i in df_cfsmsp01$mock_genspc){
#print(i)
#}
  hc<-"darkred"
  f <- colorRamp(c("pink", hc))
  zv <- df_cfsmsp01$frm[match(i,df_cfsmsp01$mock_genspc)]
  hexcol03 <- (colors <- rgb(f(zv)/255))
  df_cfsmsp01$colfm[match(i,df_cfsmsp01$mock_genspc)] <- hexcol03
}


#_______________________________________________________________________________


#___________________________________________________________________________________

#remove rows with NAs : https://stackoverflow.com/questions/4862178/remove-rows-with-all-or-some-nas-missing-values-in-data-frame
df_ncm03 <- df_ncm02[complete.cases(df_ncm02), ]

#df_ncm03 <- df_ncm02
#match back new colours to the genus_species - filtered BLAST hits
df_ncm03$col_filt_gen_spc <- df_col_f_fam07$col_filt_gen_spc[match(df_ncm03$blast_filt_genus_species,df_col_f_fam07$blast_filt_genus_species)]
#match back new colours to the genus_species - unfiltered BLAST hits
df_ncm03$col_unfilt_gen_spc <- df_col_unf_fam07$col_unfilt_gen_spc[match(df_ncm03$blast_unfilt_genus_species,df_col_unf_fam07$blast_unfilt_genus_species)]

## if color value is na, then replace with a grey hex color "#9e9e9e"
df_ncm03$col_filt_gen_spc[is.na(df_ncm03$col_filt_gen_spc)] <- "#9E9E9E"
df_ncm03$col_unfilt_gen_spc[is.na(df_ncm03$col_unfilt_gen_spc)] <- "#9E9E9E"
#length(unique(df_ncm03$col_unfilt_gen_spc))
## if gen spc name is NA then replace : see: https://datascience.stackexchange.com/questions/14273/how-to-replace-na-values-with-another-value-in-factors-in-r
levels(df_ncm03$blast_unfilt_genus_species)<-c(levels(df_ncm03$blast_unfilt_genus_species),"None")  #Add the extra level to your factor
df_ncm03$blast_unfilt_genus_species[is.na(df_ncm03$blast_unfilt_genus_species)] <- "None"           #Change NA to "None"
#change read counts to numeric
df_ncm03$seq.rd.cnt <- as.numeric(df_ncm03$seq.rd.cnt)
#make a list of unique colors
lst_col3unfilt_genspc_unq <-unique(df_ncm03$col_unfilt_gen_spc)
uufgs <- unique(df_ncm03$blast_unfilt_genus_species)
#length(uufgs)
uufgsc3 <- df_ncm03$col_unfilt_gen_spc[match(uufgs,df_ncm03$blast_unfilt_genus_species)]

#create data frame for total number of counts of each bar
total_read_count03 <- df_ncm03 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))

#split the column in genus and species name
tbl_mogen <- data.frame(do.call('rbind', strsplit(as.character(df_cfsmsp01$mock_genspc),' ',fixed=TRUE)))
# ass back to original data frame with mock species and colors
df_cfsmsp01$genus <- tbl_mogen$X1
df_cfsmsp01$species <- tbl_mogen$X2
#copy columns with colors - to be able to replace colours for mock
# species in the next part
df_ncm03$col_filt_fam_mock        <-  df_ncm03$col_filt_fam
df_ncm03$col_filt_gen_spc_mock    <-  df_ncm03$col_filt_gen_spc
df_ncm03$col_unfilt_fam_mock      <-  df_ncm03$col_unfilt_fam
df_ncm03$col_unfilt_gen_spc_mock  <-  df_ncm03$col_unfilt_gen_spc
#replace the colors
# to have a red gradient of colors for the mock species
df_ncm03$col_filt_fam_mock[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc] <- df_cfsmsp01$colfm[match((df_ncm03$blast_filt_genus_species[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc]),df_cfsmsp01$mock_genspc)]
df_ncm03$col_filt_gen_spc_mock[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc] <- df_cfsmsp01$colfm[match((df_ncm03$blast_filt_genus_species[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc]),df_cfsmsp01$mock_genspc)]
df_ncm03$col_unfilt_fam_mock[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc] <- df_cfsmsp01$colfm[match((df_ncm03$blast_filt_genus_species[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc]),df_cfsmsp01$mock_genspc)]
df_ncm03$col_unfilt_gen_spc_mock[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc] <- df_cfsmsp01$colfm[match((df_ncm03$blast_filt_genus_species[df_ncm03$blast_filt_genus_species %in% df_cfsmsp01$mock_genspc]),df_cfsmsp01$mock_genspc)]



#make a list of unique colors
lst_col3unfilt_genspc_mck_unq <-unique(df_ncm03$col_unfilt_gen_spc_mock)
lst_col3unfilt_fam_mck_unq <-unique(df_ncm03$col_unfilt_fam_mock)
lst_col3filt_fam_mck_unq <-unique(df_ncm03$col_filt_fam_mock)
lst_col3filt_gen_spc_mck_unq <-unique(df_ncm03$col_filt_gen_spc_mock)
#___________________________________________________________________________________
# start the plots 01 -  with viridis colors for mock species
#___________________________________________________________________________________
#length(as.character(lst_col3unfilt_genspc_unq))
#length(unique(df_ncm03$blast_unfilt_class_ord_fam_gen_spc))

#create 100% stacked bar plot with seqN on the x-axis
Stacked_bar_plot3 <- ggplot() +
  geom_bar(data = df_ncm03, aes(x = smpl.loc, 
                                y = seq.rd.cnt, 
                                fill = blast_unfilt_class_ord_fam_gen_spc), 
           position="fill", stat="identity") + #, color="white") +
  #Get same result with
  #geom_col(position="fill") + #, color="white") +
  #
  labs(x = "unfilt_incl_none", y = "Proportion of reads/sample",
       fill = "Sequences") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_manual(values=c(as.character(uufgsc3))) +
  guides(fill=guide_legend(ncol=1)) +
  geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.05, 
                                         label = seq.rd.cnt), vjust=0, angle = 90)
#print(Stacked_bar_plot3)

#subset data frame if observations does not match
df_ncm05 <- df_ncm03[ which(df_ncm03$blast_unfilt_class=="Actinopteri" 
                            | df_ncm03$blast_unfilt_class=="Mammalia"), ]
# unique(df_ncm03$blast_unfilt_class)
# unique(df_ncm05$blast_unfilt_class)
#get list of colors
lst_col5unfilt_genspc_unq <-unique(df_ncm05$col_unfilt_gen_spc)
#create data frame for total number of counts of each bar
total_read_count05 <- df_ncm05 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
#create 100% stacked bar plot with seqN on the x-axis
Stacked_bar_plot6 <- ggplot() +
  geom_bar(data = df_ncm05, aes(x = smpl.loc, 
                                y = seq.rd.cnt, 
                                fill = blast_unfilt_class_ord_fam_gen_spc), 
           position="fill", stat="identity") + #, color="white") +
  #Get same result with
  #geom_col(position="fill") + #, color="white") +
  labs(x = "unfilt_only_target_spc", y = "Proportion of reads/sample",
       fill = "Sequences") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_manual(values=c(as.character(lst_col5unfilt_genspc_unq))) +
  guides(fill=guide_legend(ncol=1)) +
  geom_text(data=total_read_count05, aes(x = smpl.loc, y = 1.05, 
                                         label = seq.rd.cnt), vjust=0, angle = 90)
#print(Stacked_bar_plot6)


lst_col3filt_genspc_unq <-unique(df_ncm03$col_filt_gen_spc)
#create data frame for total number of counts of each bar
total_read_count03 <- df_ncm03 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
#create 100% stacked bar plot with seqN on the x-axis
Stacked_bar_plot4 <- ggplot() +
  geom_bar(data = df_ncm03, aes(x = smpl.loc, y = seq.rd.cnt, 
                                fill = blast_filt_class_ord_fam_gen_spc), 
           position="fill", stat="identity") + #, color="white") +
  #Get same result with
  #geom_col(position="fill") + #, color="white") +
  #
  labs(x = "filt_incl_none", y = "Proportion of reads/sample",
       fill = "Sequences") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_manual(values=c(as.character(lst_col3filt_genspc_unq))) +
  guides(fill=guide_legend(ncol=1)) +
  geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.03,
                                         label = seq.rd.cnt), vjust=0, angle = 90)
#print(Stacked_bar_plot4)



#subset data frame if observations does not match
df_ncm04 <- df_ncm03[ which(!df_ncm03$blast_filt_class=="none"), ]
#get list of colors
lst_col4filt_genspc_unq <-unique(df_ncm04$col_filt_gen_spc)
#create data frame for total number of counts of each bar
total_read_count04 <- df_ncm04 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
#create 100% stacked bar plot with seqN on the x-axis
Stacked_bar_plot5 <- ggplot() +
  geom_bar(data = df_ncm04, aes(x = smpl.loc, y = seq.rd.cnt, 
                                fill = blast_filt_class_ord_fam_gen_spc), 
           position="fill", stat="identity") + #, color="white") +
  #Get same result with
  #geom_col(position="fill") + #, color="white") +
  #
  labs(x = "filt_excl_none", y = "Proportion of reads/sample",
       fill = "Sequences") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_manual(values=c(as.character(lst_col4filt_genspc_unq))) +
  guides(fill=guide_legend(ncol=1)) +
  geom_text(data=total_read_count04, aes(x = smpl.loc, y = 1.05, 
                                         label = seq.rd.cnt), vjust=0, angle = 90)
#print(Stacked_bar_plot5)



#jeg har prøvet at tilføje værdier skrevet direkte på søjlerne, men når jeg gør det forsvinder søjlerne og kun værdier er tilbage
###Figure1 <- Figure + geom_text(aes(label=seq.rd.cnt),stat="identity",position=position_dodge(0.5))

##gather bar plots in one figure
figure <- ggarrange(Stacked_bar_plot3,
                    Stacked_bar_plot4,
                    Stacked_bar_plot5,
                    Stacked_bar_plot6,
                    labels = c("A", "B", "C", "D"),
                    ncol = 1, nrow = 4)

##print results
#print(Stacked_bar_plot)
#print(Stacked_bar_plot2)
#print(figure)

# # make a sequence of capital letters
# subfiglt <- LETTERS[seq( from = 1, to = 4 )]
# ##gather 5 bar plots in one figure
# figure <- ggpubr::ggarrange(Stacked_bar_plot_per_seq,
#                             Stacked_bar_plot_per_seq,
#                             Stacked_bar_plot_per_seq,
#                             Stacked_bar_plot_per_seq,
#                             labels = c(subfiglt),
#                             ncol = 2, nrow = 2)
# figure <- Stacked_bar_plot_per_seq
#getwd()
#substitute on the input file name
filn01 <- gsub("part05_output_","",inp_fn2)
filn02 <- gsub("01.txt","",filn01)

filn02 <-"stackedbar_plot"
#paste together a new filename
plot.nm3 <- paste("part07_",libnm,"_",filn02,"01", sep="")
#plot.nm3 <- paste("part06_output_plot_on_",filn02,"02", sep="")
#print the plot in a pdf - open a pdf file
pdf(c(paste(plot.nm3,".pdf",  sep = ""))
    #set size of plot
    ,width=(1*8.2677),height=(4*3*2.9232))
#add the plot to the pdf
print(figure)
#close the pdf file again
dev.off()

#___________________________________________________________________________________

# end the plots 01 -  with viridis colors for mock species
#___________________________________________________________________________________


#make a list of unique colors
lst_col3unfilt_genspc_mck_unq <-unique(df_ncm03$col_unfilt_gen_spc_mock)
lst_col3unfilt_fam_mck_unq <-unique(df_ncm03$col_unfilt_fam_mock)
lst_col3filt_fam_mck_unq <-unique(df_ncm03$col_filt_fam_mock)
lst_col3filt_gen_spc_mck_unq <-unique(df_ncm03$col_filt_gen_spc_mock)

# #___________________________________________________________________________________
# # start the plots 02 -  with red colors for mock species
# #___________________________________________________________________________________
# 
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot3 <- ggplot() +
#   geom_bar(data = df_ncm03, aes(x = smpl.loc, 
#                                 y = seq.rd.cnt, 
#                                 fill = blast_unfilt_class_ord_fam_gen_spc), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "unfilt_incl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(as.character(lst_col3unfilt_genspc_mck_unq))) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot3)
# #print(Stacked_bar_plot4)
# #print(Stacked_bar_plot5)
# #print(Stacked_bar_plot6)
# 
# #subset data frame if observations does not match
# df_ncm05 <- df_ncm03[ which(df_ncm03$blast_unfilt_class=="Actinopteri" 
#                             | df_ncm03$blast_unfilt_class=="Mammalia"), ]
# # unique(df_ncm03$blast_unfilt_class)
# # unique(df_ncm05$blast_unfilt_class)
# #get list of colors
# lst_col5unfilt_genspc_mck_unq <-unique(df_ncm05$col_unfilt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count05 <- df_ncm05 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot6 <- ggplot() +
#   geom_bar(data = df_ncm05, aes(x = smpl.loc, 
#                                 y = seq.rd.cnt, 
#                                 fill = blast_unfilt_class_ord_fam_gen_spc), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   labs(x = "unfilt_only_target_spc", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(as.character(lst_col5unfilt_genspc_mck_unq))) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count05, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot6)
# 
# 
# lst_col3filt_genspc_mck_unq <-unique(df_ncm03$col_filt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count03 <- df_ncm03 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot4 <- ggplot() +
#   geom_bar(data = df_ncm03, aes(x = smpl.loc, y = seq.rd.cnt, 
#                                 fill = blast_filt_class_ord_fam_gen_spc), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "filt_incl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(as.character(lst_col3filt_genspc_mck_unq))) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.03,
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot4)
# 
# 
# 
# #subset data frame if observations does not match
# df_ncm04 <- df_ncm03[ which(!df_ncm03$blast_filt_class=="none"), ]
# #get list of colors
# lst_col4filt_genspc_mck_unq <-unique(df_ncm04$col_filt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count04 <- df_ncm04 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot5 <- ggplot() +
#   geom_bar(data = df_ncm04, aes(x = smpl.loc, y = seq.rd.cnt, 
#                                 fill = blast_filt_class_ord_fam_gen_spc), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "filt_excl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(as.character(lst_col4filt_genspc_mck_unq))) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count04, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot5)
# 
# 
# 
# #jeg har prøvet at tilføje værdier skrevet direkte på søjlerne, men når jeg gør det forsvinder søjlerne og kun værdier er tilbage
# ###Figure1 <- Figure + geom_text(aes(label=seq.rd.cnt),stat="identity",position=position_dodge(0.5))
# 
# ##gather bar plots in one figure
# figure <- ggarrange(Stacked_bar_plot3,
#                     Stacked_bar_plot4,
#                     Stacked_bar_plot5,
#                     Stacked_bar_plot6,
#                     labels = c("A", "B", "C", "D"),
#                     ncol = 1, nrow = 4)
# 
# ##print results
# #print(Stacked_bar_plot)
# #print(Stacked_bar_plot2)
# #print(figure)
# 
# # # make a sequence of capital letters
# # subfiglt <- LETTERS[seq( from = 1, to = 4 )]
# # ##gather 5 bar plots in one figure
# # figure <- ggpubr::ggarrange(Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             labels = c(subfiglt),
# #                             ncol = 2, nrow = 2)
# # figure <- Stacked_bar_plot_per_seq
# #getwd()
# #substitute on the input file name
# filn01 <- gsub("part05_output_","",inp_fn2)
# filn02 <- gsub("02.txt","",filn01)
# 
# filn02 <-"stackedbar_plot"
# #paste together a new filename
# plot.nm3 <- paste("part07_",libnm,"_",filn02,"02", sep="")
# #plot.nm3 <- paste("part06_output_plot_on_",filn02,"02", sep="")
# #print the plot in a pdf - open a pdf file
# pdf(c(paste(plot.nm3,".pdf",  sep = ""))
#     #set size of plot
#     ,width=(1*8.2677),height=(4*3*2.9232))
# #add the plot to the pdf
# print(figure)
# #close the pdf file again
# dev.off()
# 
# #___________________________________________________________________________________
# 
# # end the plots 02
# #___________________________________________________________________________________
# 

# #___________________________________________________________________________________
# # start the plots 03 -  with red colors for mock species
# #___________________________________________________________________________________
# 
# 
# #copy columns with colors - to be able to replace colours for mock
# # species in the next part
# df_ncm03$cffm2    <-  df_ncm03$col_filt_fam_mock
# df_ncm03$cfgsm2   <-  df_ncm03$col_filt_gen_spc_mock
# df_ncm03$cunffm2  <-  df_ncm03$col_unfilt_fam_mock
# df_ncm03$cunfgsm2 <-  df_ncm03$col_unfilt_gen_spc_mock
# 
# #https://stackoverflow.com/questions/42891307/how-can-i-maintain-a-color-scheme-across-ggplots-while-dropping-unused-levels-i
# #make a colour range tha is unique 
# bfcofgs <-   setNames( c(unique(df_ncm03$cffm2))
#                        , levels(as.factor(df_ncm03$blast_filt_fam))  )
# 
# bfggs <-   setNames( c(unique(df_ncm03$cfgsm2))
#                      , levels(as.factor(df_ncm03$blast_filt_genus_species))  )
# 
# bufff <-   setNames( c(unique(df_ncm03$cunffm2))
#                      , levels(as.factor(df_ncm03$blast_unfilt_fam))  )
# 
# bufgs <-   setNames( c(unique(df_ncm03$cunfgsm2))
#                      , levels(as.factor(df_ncm03$blast_unfilt_genus_species))  )
# 
# 
# 
# 
# 
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot3 <- ggplot() +
#   geom_bar(data = df_ncm03, aes(x = smpl.loc, 
#                                 y = seq.rd.cnt, 
#                                 fill = blast_unfilt_fam), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "unfilt_incl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(bufff)) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot3)
# #print(Stacked_bar_plot4)
# #print(Stacked_bar_plot5)
# #print(Stacked_bar_plot6)
# 
# #subset data frame if observations does not match
# df_ncm05 <- df_ncm03[ which(df_ncm03$blast_unfilt_class=="Actinopteri" 
#                             | df_ncm03$blast_unfilt_class=="Mammalia"), ]
# # unique(df_ncm03$blast_unfilt_class)
# # unique(df_ncm05$blast_unfilt_class)
# #get list of colors
# lst_col5unfilt_genspc_mck_unq <-unique(df_ncm05$col_unfilt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count05 <- df_ncm05 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot6 <- ggplot() +
#   geom_bar(data = df_ncm05, aes(x = smpl.loc, 
#                                 y = seq.rd.cnt, 
#                                 fill = blast_unfilt_genus_species), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   labs(x = "unfilt_only_target_spc", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c( bufgs)) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count05, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot6)
# 
# 
# lst_col3filt_genspc_mck_unq <-unique(df_ncm03$col_filt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count03 <- df_ncm03 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot4 <- ggplot() +
#   geom_bar(data = df_ncm03, aes(x = smpl.loc, y = seq.rd.cnt, 
#                                 fill = blast_filt_fam), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "filt_incl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(bfcofgs )) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count03, aes(x = smpl.loc, y = 1.03,
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot4)
# 
# 
# 
# 
# 
# 
# #subset data frame if observations does not match
# df_ncm04 <- df_ncm03[ which(!df_ncm03$blast_filt_class=="none"), ]
# #get list of colors
# lst_col4filt_genspc_mck_unq <-unique(df_ncm04$col_filt_gen_spc_mock)
# #create data frame for total number of counts of each bar
# total_read_count04 <- df_ncm04 %>% group_by(smpl.loc) %>% summarise(seq.rd.cnt = sum(seq.rd.cnt))
# #create 100% stacked bar plot with seqN on the x-axis
# Stacked_bar_plot5 <- ggplot() +
#   geom_bar(data = df_ncm04, aes(x = smpl.loc, y = seq.rd.cnt, 
#                                 fill = blast_filt_genus_species), 
#            position="fill", stat="identity") + #, color="white") +
#   #Get same result with
#   #geom_col(position="fill") + #, color="white") +
#   #
#   labs(x = "filt_excl_none", y = "Proportion of reads/sample",
#        fill = "Sequences") +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_fill_manual(values=c(bfggs)) +
#   guides(fill=guide_legend(ncol=1)) +
#   geom_text(data=total_read_count04, aes(x = smpl.loc, y = 1.05, 
#                                          label = seq.rd.cnt), vjust=0, angle = 90)
# #print(Stacked_bar_plot5)
# 
# 
# 
# 
# #jeg har prøvet at tilføje værdier skrevet direkte på søjlerne, men når jeg gør det forsvinder søjlerne og kun værdier er tilbage
# ###Figure1 <- Figure + geom_text(aes(label=seq.rd.cnt),stat="identity",position=position_dodge(0.5))
# 
# ##gather bar plots in one figure
# figure <- ggarrange(Stacked_bar_plot3,
#                     Stacked_bar_plot4,
#                     Stacked_bar_plot5,
#                     Stacked_bar_plot6,
#                     labels = c("A", "B", "C", "D"),
#                     ncol = 1, nrow = 4)
# 
# ##print results
# #print(Stacked_bar_plot)
# #print(Stacked_bar_plot2)
# #print(figure)
# 
# # # make a sequence of capital letters
# # subfiglt <- LETTERS[seq( from = 1, to = 4 )]
# # ##gather 5 bar plots in one figure
# # figure <- ggpubr::ggarrange(Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             Stacked_bar_plot_per_seq,
# #                             labels = c(subfiglt),
# #                             ncol = 2, nrow = 2)
# # figure <- Stacked_bar_plot_per_seq
# #getwd()
# #substitute on the input file name
# filn01 <- gsub("part05_output_","",inp_fn2)
# filn02 <- gsub("02.txt","",filn01)
# 
# filn02 <-"stackedbar_plot"
# #paste together a new filename
# plot.nm3 <- paste("part07_",libnm,"_",filn02,"03", sep="")
# #plot.nm3 <- paste("part06_output_plot_on_",filn02,"02", sep="")
# #print the plot in a pdf - open a pdf file
# pdf(c(paste(plot.nm3,".pdf",  sep = ""))
#     #set size of plot
#     ,width=(1*8.2677),height=(4*3*2.9232))
# #add the plot to the pdf
# print(figure)
# #close the pdf file again
# dev.off()
# 
# #___________________________________________________________________________________
# # end the plots 03 -  with red colors for mock species
# #___________________________________________________________________________________
# 


#____________________________________________________________________________________
# make a csv-table for the blast hits - start
#____________________________________________________________________________________

#head(df_ncm04,10)
df_ncm04$seq.rd.cnt
keeps <- c(
  "blast_unfilt_genus_species",
  "seq.rd.cnt"
)
df_ncm06 <- df_ncm03[keeps] #species names assigned unfiltered including all
# count up the total count of sequence reads per species : https://stackoverflow.com/questions/57328395/how-to-perform-sum-and-count-on-dataframe-in-r
df_ncm07 <- aggregate(cbind(seq.rd.cnt) ~ blast_unfilt_genus_species, 
          transform(df_ncm06, Count = 1), sum)
#keep only selected columns
df_spa_ufall_01 <- df_ncm03[keeps] #species names assigned unfiltered including all
#check the column names
#colnames(df_ncm04)
#define the columns to keep 
keeps <- c(
            "blast_unfilt_fam",
            "blast_unfilt_genus_species",
            "blast_filt_fam",
            "blast_filt_genus_species"
            )
#keep only selected columns
df_spa_ufall_01 <- df_ncm03[keeps] #species names assigned unfiltered including all
df_spa_fexno_01 <- df_ncm04[keeps] #species names assigned filtered excluding 'none'
df_spa_unfoa_01 <- df_ncm05[keeps] #species names assigned unfiltered only Actinopterygii

# Only retain unique rows: 
# https://stats.stackexchange.com/questions/6759/removing-duplicated-rows-data-frame-in-r
df_spa_ufall_02 <- df_spa_ufall_01[!duplicated(df_spa_ufall_01), ]
df_spa_fexno_02 <- df_spa_fexno_01[!duplicated(df_spa_fexno_01), ]
df_spa_unfoa_02 <- df_spa_unfoa_01[!duplicated(df_spa_unfoa_01), ]

# define a function: https://stackoverflow.com/questions/15162197/combine-rbind-data-frames-and-create-column-with-name-of-original-data-frames
AppenDFsourc <- function(dfNames) {
  do.call(rbind, lapply(dfNames, function(x) {
    cbind(get(x), source = x)
  }))
}
# use the function to bind rows in data frames keeping the source of the data frames
df_spa_03 <- AppenDFsourc(c("df_spa_ufall_02",
               "df_spa_fexno_02",
               "df_spa_unfoa_02"))
#replace in the column for the source
df_spa_03$source <- gsub('df_spa_ufall_02', 'unfilt_all', df_spa_03$source)
df_spa_03$source <- gsub('df_spa_fexno_02', 'filt_excl_none', df_spa_03$source)
df_spa_03$source <- gsub('df_spa_unfoa_02', 'unfilt_only_Actinopterygi', df_spa_03$source)
#unique(df_spa_03$source)
# read in table with comments from PRM
#df_evaluat <- read.table("part07_comments_PRM_per_species01.csv",sep=",", header = T)
# set 'fill=T' to TRUE to make sure that tables with irregular number of columns are read in as well
df_evaluat <- read.table(inp_fn4,sep=",", header = T, fill=T)
df_evaluat$blast_filt_genus_species <- df_evaluat$species_after_filtration
#colnames(df_evaluat)
#replace underscores with spaces
df_evaluat$species_after_filtration <- gsub("_"," ",df_evaluat$blast_filt_genus_species)
#match notes and comments back
df_spa_03$note <- df_evaluat$note[match(df_spa_03$blast_unfilt_genus_species,df_evaluat$blast_unfilt_genus_species)]
#df_spa_03$SWK_spm1 <- df_evaluat$SWK_spm1[match(df_spa_03$blast_unfilt_genus_species,df_evaluat$blast_unfilt_genus_species)]
df_spa_03$Oceanic_region <- df_evaluat$Oceanic_region[match(df_spa_03$blast_unfilt_genus_species,df_evaluat$blast_unfilt_genus_species)]
df_spa_03$commentary<- df_evaluat$commentary[match(df_spa_03$blast_unfilt_genus_species,df_evaluat$blast_unfilt_genus_species)]
df_spa_03$ngs_metabarcode_libr_nm <- libnm
df_spa_03$seq.rd.cnt <- df_ncm07$seq.rd.cnt[match(df_spa_03$blast_unfilt_genus_species,df_ncm07$blast_unfilt_genus_species)]
# define working directory
#my_wd <- "/home/hal9000/metabarcode_example/JMS_FL/1-demultiplexed"
# #set working directory
#setwd(my_wd)
csv_fnm <- paste("part07_",libnm,"_otus_blast.csv",sep="")
# write the data frame to a csv file
write.csv(df_spa_03,
          csv_fnm,
          row.names = FALSE)

#setwd(my_wd)
csv_fnm2 <- paste("part07_",libnm,"_otus_blast_ncm.csv",sep="")

# write the data frame to a csv file
write.csv(df_ncm03,
          csv_fnm2,
          row.names = FALSE)
#____________________________________________________________________________________
# make a csv-table for the blast hits - end
#____________________________________________________________________________________

#


#######
