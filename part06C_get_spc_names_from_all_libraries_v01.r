#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#################################################################################
#
# Code developed for analysis of metabarcode NGS data
# obtained with NGS
#
# code prepared by  Steen Wilhelm Knudsen
# in Oct-2021 at the Zoological Museum of Copenhagen
##______________________________________________________________________________
# # make a list of species found in all libraries
# lib_path01 <- "/groups/hologenomics/phq599/data/R_packages_for_Rv4_0_2"
# Sys.setenv(R_LIBS_USER="lib_path01")
# .libPaths("lib_path01")
# # change the path to where the packages should be installed from # see this website: https://stackoverflow.com/questions/15170399/change-r-default-library-path-using-libpaths-in-rprofile-site-fails-to-work
# .libPaths( c( lib_path01 , .libPaths() ) )
# .libPaths()
##______________________________________________________________________________

wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv"
setwd(wd00)
#define input file with list of species
infile03 <- "part05_lst_species_of_marine_fish_in_DK.txt"
#define input file with list of mock species
infile04 <- "part05_lst_species_in_PCmock.txt"
#read in the list
df_L01 <- read.csv(infile03, header = F)
df_M01 <- read.csv(infile04, header = F)
#change the column name
colnames(df_L01) <- "genus_species"
colnames(df_M01) <- "genus_species"
#wd00 <- getwd()
#get list of files
lstfi01<- list.files(paste(wd00,sep=""))
inbibfl <- lstfi01[grepl("allbibs",lstfi01)]
inbibfl2 <- inbibfl[grepl("\\.txt",inbibfl)]

#make a list to hold txt files read in
ls.spcslist <- list()
#
i <- 1
#iterate over files
for (file in inbibfl2)
{
  #read in as a tibble
  tbl_txt <- read.table(file,sep="\t",header=TRUE,stringsAsFactors = FALSE )
  df_txt <- as.data.frame(tbl_txt, stringsAsFactors = FALSE)
  #add data frame to list of data frames
  ls.spcslist[[i]] <- df_txt
  # add to the increasing number for next iteration
  i <- i+1
}
#make the nested list a data frame
df_spcl <- as.data.frame(do.call(rbind, ls.spcslist))
#combine the dataframes in to one
#https://stats.stackexchange.com/questions/244486/rbind-for-dataframes-with-different-number-of-rows
df_S01 <- plyr::rbind.fill(df_spcl)
df_S02 <- unique(df_S01)
#order the columns by species
df_S03 <- df_S02[order(df_S02$species), ]
#limit to only Chordata
df_S03  <- df_S03[grepl("Chordata",df_S03$phylum),]
#exclude rows with species that have numbers
df_S03  <- df_S03[!grepl("[0-9]+",df_S03$species),]
#add columns
df_S03$note <- NA
df_S03$Oceanic_region <- NA
df_S03$commentary <- NA
#see which species from the libraries also are in the list of plausible species
#df_S03$species[df_S03$species %in% df_L01$genus_species]
#see which species from the libraries are NOT in the list of plausible species
#df_S03$species[!df_S03$species %in% df_L01$genus_species]
#For the species that are in the list of plausible species, assign them an 'ok' note
df_S03$note[df_S03$species %in% df_L01$genus_species] <- "ok"
df_S03$Oceanic_region[df_S03$species %in% df_L01$genus_species] <- "N_Atlantic"
# make a note for the terrestrial mammals
df_S03$note[df_S03$class=="Mammalia"][grepl("Sus ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$note[df_S03$class=="Mammalia"][grepl("Bos ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$note[df_S03$class=="Mammalia"][grepl("Felis ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$note[df_S03$class=="Mammalia"][grepl("Canis ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$note[df_S03$class=="Mammalia"][grepl("Homo ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
# make a note for the terrestrial mammals
df_S03$Oceanic_region[df_S03$class=="Mammalia"][grepl("Sus ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$Oceanic_region[df_S03$class=="Mammalia"][grepl("Bos ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$Oceanic_region[df_S03$class=="Mammalia"][grepl("Felis ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$Oceanic_region[df_S03$class=="Mammalia"][grepl("Canis ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"
df_S03$Oceanic_region[df_S03$class=="Mammalia"][grepl("Homo ",df_S03$species[df_S03$class=="Mammalia"])] <- "terrestrial_mammal"

#add a note for seagulls
df_S03$note[df_S03$class=="Aves"][grepl("Larus",df_S03$species[df_S03$class=="Aves"])] <- "seagull"
#add a note for passerine birds
df_S03$note[df_S03$class=="Aves"][grepl("Poecile",df_S03$species[df_S03$class=="Aves"])] <- "passerine bird"
#split column in two
df_L02 <- data.frame(do.call('rbind', strsplit(as.character(df_L01$genus_species),' ',fixed=T)))
colnames(df_L02) <- c("genus","species")
#get a list of local genera
lst_L02gen <- unique(df_L02$genus)

# iterate over genera for the area
for (locgen in lst_L02gen){
  #add a note for the local genera species
  df_S03$note[is.na(df_S03$note)][grepl(locgen,df_S03$genus[is.na(df_S03$note)])] <- "likely_a_match_with_a_local_genus"
}
#make a list of mock species
lst_mspc <-  df_M01$genus_species
# iterate over genera for mock species
for (mspc in lst_mspc){
  #print(mspc)
  #add a note for the mock species
  df_S03$note[grepl(mspc,df_S03$species)] <- "mockspecies"  
}
#limit the list of valid species to only comprise the mock species
# and the DK marine  species that are known to occur in the seas around
# Denmark
# comment out this line if you want the list of possible relevant
# species to comprise other matches with the other mock related species
df_S03 <- df_S03[!is.na(df_S03$note),]
#define list of mock genera in mock species
mockspecs <- 
  c("Kyphosus",
"Carcharhinus",
"Aphyonus",
"Lampanichthys",
"Pseudoginglymostoma",
"Pomacanthus",
"Acanthopagrus",
"Scarus")
# iterate over genera for mock species
for (mspc in mockspecs){
  #add a note for the mock species
  df_S03$note[grepl(mspc,df_S03$species)] <- "mockspecies"  
}
#define a list of mock orders
mckords <- c(
             "Galeomorfi",
             "Ophidiiformes",
             "Myctophiformes",
             "Orectolobiformes",
             "Perciformes")
# iterate over genera for mock orders
for (mord in mckords){
  #add a note for the mock species
  df_S03$note[is.na(df_S03$note)][grepl(mord,df_S03$order[is.na(df_S03$note)])] <- "likely_mockspecies_match"
}

#define list of mock related genera among mock species
rgmockspecs <- 
  c("Lutjanus",
    "Diagramma",
    "Monodactylus",
    "Plectorhinchus",
    "Acanthurus",
    "Chlorurus",
    "Pinjalo",
    "Rhabdosargus")
# iterate over genera for mock species
for (rgmspc in rgmockspecs){
  #add a note for the mock species
  df_S03$note[is.na(df_S03$note)][grepl(rgmspc,df_S03$genus[is.na(df_S03$note)])] <- "likely_mockspecies_match"
}

#unique(df_S03$genus[is.na(df_S03$note)])



df_S03$species_after_filtration <- df_S03$species 
#define columns to keep
keeps <- c("species_after_filtration",
           "note",
           "Oceanic_region",
           "commentary")
# keep only these coulmns
df_S04 <- df_S03[keeps]
#write out the evaluations file
outfl <- "part07_list_of_blasthits_evaluations.txt"
write.table(df_S04,file=outfl,sep=",",col.names = T,row.names = F,quote = F)
