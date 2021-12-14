#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-


#remove everything in the working environment, without a warning!!
rm(list=ls())

library("dplyr")
library("ggplot2")
#Define major work directory
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv_v02/"
#Define output  directory  
wd08 <- "part08_out_analysis_from_csv"
# define input directory for input files
wd07 <- "csv_files_from_part07_2021dec10"
#make complete path to input dir
wd00_wd08 <- paste(wd00,"/",wd08,sep="")
#make complete path to output dir
wd00_wd07 <- paste(wd00,"/",wd07,sep="")
#check the wd
#getwd()
#Delete any previous versions of the output directory
unlink(wd00_wd08, recursive=TRUE)
#Create a directory to put resulting output files in
dir.create(wd00_wd08)
#list the files in the input directory
lf_p07 <- list.files(wd00_wd07)
#grep after tar files
lft_07 <- lf_p07[grep("tar",lf_p07)]
# get path for file with original sampling locations 
wd_ex1 <- "/home/hal9000/Documents/Documents/NIVA_Ansaettelse_2019sep/NISAR_analysis"
# get file with original sampling locations
inf2 <- "MST_samples_2017_2018.csv"

#paste path together with the input file
pft_07 <- paste(wd00_wd07,"/",lft_07,sep="")
pft_in2 <- paste(wd_ex1,"/",inf2,sep="")
#uncompress the tar file
untar(pft_07, exdir=wd00_wd08) 
#list files that have been uncompressed
lf_p08 <- list.files(wd00_wd08)
lf_p08 <- lf_p08[grep("ncm",lf_p08)]
# copy the file to the new folder
file.copy(pft_in2, wd00_wd07)
#read in file with sampling locations
dfM01 <- read.csv(pft_in2,header = T, stringsAsFactors = F,
                  sep=",")
# make a number to count elements
i <- 1
# make an empty list
lsf2 <- list()
#iterate over csv files in list
for (f in lf_p08)
{
#   print(f)
# }
fp <- paste(wd00_wd08,"/",f,sep="")
  #read in the file as a df
  dfs01 <- as.data.frame(read.csv(fp,
                                  header = TRUE, 
                                  sep = ",", quote = "\"",
                                  dec = ".", fill = TRUE, 
                                  comment.char = "", 
                                  stringsAsFactors = FALSE))
  # add the filename as a varirable
  dfs01$flnm <- as.character(f)
  #make sure all columns are characters
  # to allow dplyr to combine them all
  #https://stackoverflow.com/questions/43789278/convert-all-columns-to-characters-in-a-data-frame
  dfs01 <- dfs01 %>%
    mutate_all(as.character)
  # add it to the list
  lsf2[[i]] <- dfs01 
  # add to the increasing count
  i <- i+1
  #end iteration over files
}

#bind rows together 
# with dplyr 
# https://stackoverflow.com/questions/16138693/rbind-multiple-data-sets
tbl_lsf2 <- bind_rows(lsf2)
df02 <- as.data.frame(tbl_lsf2)
#split string
fls01 <- data.frame(do.call('rbind', strsplit(as.character(df02$flnm),'_',fixed=TRUE)))
spl01 <- data.frame(do.call('rbind', strsplit(as.character(df02$smpl.loc),'_',fixed=TRUE)))
#get library number
df02$bNo <- fls01$X2
# get MST sample number, primerset and tag number
df02$MSTNo    <- spl01$X1
df02$prmset   <- spl01$X2
df02$tagno    <- spl01$X3
#make a column for the primerset anfd MST sample No
df02$MSTNo_smpln <- paste(df02$MSTNo,"_",df02$prmset,sep="")
#exclude the 'none' match from the data frame
# this should exclude the majority of the procaryote reads
df03 <- df02[!df02$blast_filt_class=="none",]
#make numeric to be able to sum up read counts
df03$seq.rd.cnt <- as.numeric(df03$seq.rd.cnt)
head(df03,5)
# get the dplyr package
library(dplyr)
# use the dplyr package to count up read counts per Sample site_primerset
tibl_03 <- df03 %>%
  group_by(MSTNo_smpln) %>%
  summarise(Freq = sum(seq.rd.cnt ))
# match between MSTsampleNo and primerset between data frames
# to get total read count per primerset per locality back to
# main data frame
df03$trcpl <-  tibl_03$Freq[match(df03$MSTNo_smpln,tibl_03$MSTNo_smpln)]
# use the dplyr package to count up read counts per Sample site 
# per class_family_genus_species
# see this question: https://stackoverflow.com/questions/36893812/using-dplyr-to-summarize-by-multiple-groups
tibl_04 <- group_by(df03,MSTNo_smpln,blast_filt_class_ord_fam_gen_spc) %>%
  summarise(Freq = sum(seq.rd.cnt ))
#make the tibble a data frame
df04 <- as.data.frame(tibl_04)
df04$MSTNo_smpln
#split string
smpr <- data.frame(do.call('rbind', strsplit(as.character(df04$MSTNo_smpln),'_',fixed=TRUE)))
# append back to data frame
df04$MSTNo <- smpr$X1
df04$prmst <- smpr$X2
#rename column
colnames(df04)[3] <- "sum_rdcnt"
#substitute to get the fourth element retained
df04$gnsp <- gsub("^(*.*)_(*.*)_(*.*)_(*.*)$","\\4",df04$blast_filt_class_ord_fam_gen_spc)
#get columns with 'col' in the column names, and place in a vector
ccl <- colnames(df02)[grep("col",colnames(df02))]
#iterate over these columns
for (cl in ccl)
#start iteration
  {
  #match back hex color for category for column from original data frame 
  df04[,cl] <- (df02[,cl])[match(df04$blast_filt_class_ord_fam_gen_spc,df02$blast_filt_class_ord_fam_gen_spc)]
  #get number of unique elements
  lcl<- length(unique(df04[,cl] ))
  #print the unique elements to screen
  print(cl)
  print(lcl)
  #end iteration
    }

#get all non PCMock samples
df05 <- df04[!grepl("PCMock",df04$MSTNo_smpln),]
#get all non NC_ samples
df05 <- df05[!grepl("NC_",df05$MSTNo_smpln),]
# get uniqe colors for species 
cufgs <- unique(df05$col_unfilt_gen_spc)
#make stacked bar plot with ggplot2
stbp01 <- ggplot(df05,aes(MSTNo,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  xlab("MST sample no")+
  ylab("percentage of reads")+
  scale_fill_manual(values = cufgs)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%"))+
  ggtitle("A - fish reads two primersets")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~prmst)
stbp01
# make rainbow colour range
rbwclr <- rainbow(length(unique(df05$blast_filt_class_ord_fam_gen_spc)))
# make viridis colour range
vclr <- pals::viridis(length(unique(df05$blast_filt_class_ord_fam_gen_spc)))
#make stacked bar plot with ggplot2
stbp02 <- ggplot(df05,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  xlab("primer set name")+
  ylab("percentage of reads")+
  scale_fill_manual(values = rbwclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%"))+
  ggtitle("B - fish reads two primersets")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~MSTNo)
stbp02
#make stacked bar plot with ggplot2
stbp03 <- ggplot(df05,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  xlab("primer set name")+
  ylab("percentage of reads")+
  scale_fill_manual(values = vclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%"))+
  ggtitle("B - fish reads two primersets")+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~MSTNo)
stbp03


#subset data frame by two criteria
dfM235M <- df04[df04$MSTNo=="MST235" & df04$prmst=="MiFiU",]
# Create data for the graph.
labls <- dfM235M$gnsp
srdc <- dfM235M$sum_rdcnt
# Plot the chart with title and rainbow color pallet.
pie(srdc, labls, main = "MST235 and MiFiU", col = rainbow(length(srdc)))


#subset data frame by two criteria
dfM235M <- df04[df04$MSTNo=="MST235" & df04$prmst=="DiBat",]
# Create data for the graph.
labls <- dfM235M$gnsp
srdc <- dfM235M$sum_rdcnt
# Plot the chart with title and rainbow color pallet.
pie(srdc, labls, main = "MST235 and DiBat", col = rainbow(length(srdc)))

head(df04,7)


# #https://towardsdatascience.com/using-ggplot-to-plot-pie-charts-on-a-geographical-map-bb54d22d6e13
# #plot pies on map
# wmp <- ggplot2::map_data("world")
# 
# mapplot1 <- ggplot2::ggplot(wmp) + 
#   ggplot2::geom_map(data = wmp, map = wmp, 
#                     ggplot2::aes(x=long, y=lat, map_id=region), 
#            col = "white", fill = "gray50") +
#   geom_scatterpie(aes(x=longitude, y=latitude, 
#                       group = country, r = multiplier*6), 
#                   data = final_data, cols = colnames(final_data[,c(2:11)]))
# 
# mapplot1

#get unique library numbers
ulbn <- unique(df03$bNo)
ulbn <- "b009"
#iterate over library numbers
for (bn in ulbn)
{print(bn)
  
  df03 <- df02[df02$bNo==bn,]

    }





#
#
#
