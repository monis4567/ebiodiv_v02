#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-


#remove everything in the working environment, without a warning!!
rm(list=ls())

if(!require("dplyr")){
  install.packages("dplyr", dependencies = TRUE, INSTALL_opts = '--no-lock')
  library("dplyr")
}
library("dplyr")

if(!require("ggplot2")){
  install.packages("ggplot2", dependencies = TRUE, INSTALL_opts = '--no-lock')
  library("ggplot2")
}
library("ggplot2")
if(!require("shadowtext")){
  install.packages("shadowtext", dependencies = TRUE, INSTALL_opts = '--no-lock')
  library("shadowtext")
}
library("shadowtext")

#Define major work directory
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/ebiodiv_v02"
#Define output  directory  
wd08 <- "part08_out_analysis_from_csv"
# define input directory for input files
wd07 <- "csv_files_from_part07_2021dec10"
wd07 <- "csv_files_from_part07_2022jan04"
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
#make a column for the primerset and MST sample No
df02$MSTNo_smpln <- paste(df02$MSTNo,"_",df02$prmset,sep="")
#exclude the 'none' match from the data frame
# this should exclude the majority of the procaryote reads
df03 <- df02[!df02$blast_filt_class=="none",]
#make numeric to be able to sum up read counts
df03$seq.rd.cnt <- as.numeric(df03$seq.rd.cnt)
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
  # #print the unique elements to screen
  # print(cl)
  # print(lcl)
  #end iteration
    }

#get all non PCMock samples
df05 <- df04[!grepl("PCMock",df04$MSTNo_smpln),]
#get all non NC_ samples
df05 <- df05[!grepl("NC_",df05$MSTNo_smpln),]
# get uniqe colors for species 
cufgs <- unique(df05$col_unfilt_gen_spc)

#_______________________________________________________________________________
# make stacked bar plots - start
#_______________________________________________________________________________
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
# see the plot
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
# see the plot
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
# see the plot
stbp03

#_______________________________________________________________________________

#add back the total count of reads for sample site per primerset
# calculated in the tibble
df05$totrcnt <- tibl_03$Freq[match(df05$MSTNo_smpln,tibl_03$MSTNo_smpln)]
# use dplyr to count per group and use mutate to calculate the
# mid point position for placing the text label in the middle of the section of
# thre staacked bar plots
tibl06 <- df05 %>% group_by(gnsp, prmst, MSTNo) %>%
  #tally(sum_rdcnt) %>% 
  ungroup %>%
  arrange(desc(gnsp)) %>% 
  #group_by(prmst, MSTNo) %>% 
  #mutate(pos = (cumsum(sum_rdcnt)/totrcnt*100 -sum_rdcnt/cumsum(sum_rdcnt)/totrcnt*100)/2)
  mutate(pos = 1- 0.5*sum_rdcnt/totrcnt*100) #%>%
#add a line break to species names
# tibl06 <- tibl06 %>%
#     mutate(gnsp2=stringr::str_replace(gnsp," ","\n"))

# make rainbow colour range
rbwclr <- rainbow(length(unique(tibl06$blast_filt_class_ord_fam_gen_spc)))
# make viridis colour range
vclr <- pals::viridis(length(unique(tibl06$blast_filt_class_ord_fam_gen_spc)))
#make stacked bar plot with ggplot2
stbp04 <- ggplot(tibl06,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  
  geom_text(aes(y =sum_rdcnt, label = gnsp), 
            position=position_fill(vjust=0.5), size=2) +
  
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
# see the plot
stbp04
#_______________________________________________________________________________

#add back the total count of reads for sample site per primerset
# calculated in the tibble
df05$totrcnt <- tibl_03$Freq[match(df05$MSTNo_smpln,tibl_03$MSTNo_smpln)]
# use dplyr to count per group and use mutate to calculate the
# mid point position for placing the text label in the middle of the section of
# thre staacked bar plots
tibl06 <- df05 %>% group_by(gnsp, prmst, MSTNo) %>%
  #tally(sum_rdcnt) %>% 
  ungroup %>%
  arrange(desc(gnsp)) %>% 
  #group_by(prmst, MSTNo) %>% 
  #mutate(pos = (cumsum(sum_rdcnt)/totrcnt*100 -sum_rdcnt/cumsum(sum_rdcnt)/totrcnt*100)/2)
  mutate(pos = 1- 0.5*sum_rdcnt/totrcnt*100) #%>%
#add a line break to species names
tibl06 <- tibl06 %>%
  mutate(gnsp2=stringr::str_replace(gnsp," ","\n"))

# make rainbow colour range
rbwclr <- rainbow(length(unique(tibl06$blast_filt_class_ord_fam_gen_spc)))
# make viridis colour range
vclr <- pals::viridis(length(unique(tibl06$blast_filt_class_ord_fam_gen_spc)))
#make stacked bar plot with ggplot2
stbp05 <- ggplot(tibl06,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  
  geom_text(aes(y =sum_rdcnt, label = gnsp2), 
            position=position_fill(vjust=0.5), size=2) +
  
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
# see the plot
stbp05

#_______________________________________________________________________________
#Følgende kode laver labels (tibl06$gnsp2) kun til bars hvor sum_rdcnt er mindst 3% af total
#Så bliver de mindste bars uden labels.
tibl06 <- tibl06 %>%
  group_by(MSTNo,prmst) %>%
  mutate(pct=100*sum_rdcnt/sum(sum_rdcnt,na.rm=T)) %>%
  ungroup() %>%
  mutate(gnsp2=ifelse(pct>3,
                      stringr::str_replace(gnsp," ","\n"),
                      ""))
#Har også et par andre forslag til figuren:
#Legenden flyttet ltil højre side
#Legend.key.size er sat til 0.58 cm (størrelsen på de
#farvede firkanter i legenden).
#Det passer med at jeg gemmer png fil i størrelsen 20x30cm.
#Det skal justeres for andre størrelser.
#Tomt rum omkring kollenerne fjernet med expand=F i funktionen coord_cartesian

stbp06 <- ggplot(tibl06,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  geom_text(aes(y =sum_rdcnt, label = gnsp2), position=position_fill(vjust=0.5), 
            size=2, fontface="italic") +
  xlab("primer set name")+
  ylab("percentage of reads")+
  scale_fill_manual(values = rbwclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%")) +
  ggtitle("B - fish reads two primersets")+
  guides(fill= guide_legend(ncol=1)) +
  theme(legend.position = "right",
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        legend.key.size = unit(0.57,"cm"),
        legend.justification = "bottom",       
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~MSTNo) +
  coord_cartesian(expand=F)
# see the plot
stbp06
outppthf6 <- paste(wd00_wd08,"/Fig06_stckbarplot_02.png",sep="")

ggsave(stbp06,file=outppthf6,height=20,width=30,units="cm",dpi=300)


#______________________________________________________________________________

stbp07 <- ggplot(tibl06,aes(prmst,sum_rdcnt ,fill = gnsp))+
  geom_bar(position = "fill",stat="identity", width = 0.9, 
           #the 'color="#000000",size=0.1' adds a thin line between 
           # individual parts of the bar in the satcked bar
           color="#000000",size=0.1)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  geom_text(aes(y =sum_rdcnt, label = gnsp2), position=position_fill(vjust=0.5), 
            size=2, fontface="italic") +
  xlab("primer set name")+
  ylab("percentage of reads from eukaryotes")+
  scale_fill_manual(values = vclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%")) +
  ggtitle("B - fish reads two primersets, procaryotes excluded")+
  guides(fill= guide_legend(ncol=1)) +
  theme(legend.position = "right",
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        legend.key.size = unit(0.57,"cm"),
        legend.justification = "bottom",       
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~MSTNo) +
  coord_cartesian(expand=F)
# see the plot
stbp07
outppthf7 <- paste(wd00_wd08,"/Fig07_stckbarplot_02.png",sep="")

ggsave(stbp07,file=outppthf7,height=20,width=30,units="cm",dpi=300)

# make stacked bar plots - end
#_______________________________________________________________________________



#_______________________________________________________________________________
# plot pies on maps - start
#_______________________________________________________________________________


# reshape the data frame for long to wide
df07 <- reshape(data=df05,idvar="MSTNo_smpln",
                v.names = "sum_rdcnt",
                #timevar = " blast_filt_class_ord_fam_gen_spc",
                timevar = "gnsp",
                direction="wide")
#make a list of columns to modify
cltm <- colnames(df07)[grepl("sum_rdcnt\\.",colnames(df07))]
#Replace NAs in multiple columns
df07[,c(cltm)][is.na(df07[,c(cltm)])] <- 0
#get column numbers that match
clnmm <- match(cltm,names(df07))
#sum up for each row
df07$rws <- rowSums(df07[,clnmm])
rws <- as.numeric(df07$rws)

#rename columns that have read count appended
#colnames(df07)[grepl("sum_rdcnt\\.",colnames(df07))] <- gsub("sum_rdcnt\\.","",cltm)

#head(df07,8)
#colnames(df07)
#get latitude and longitude from data frame w sample collection data
df07$lat <- dfM01$lok_pos_lat[match(df07$MSTNo,dfM01$U_Pr_Nr)]
df07$lon <- dfM01$lok_pos_lon[match(df07$MSTNo,dfM01$U_Pr_Nr)]
#get sampling date
df07$date <- dfM01$Dato_inds[match(df07$MSTNo,dfM01$U_Pr_Nr)]
# make second skewed longitude for the two primersets
df07$lon2 <- NA
df07$lon2[df07$prmst=="DiBat"] <- df07$lon[df07$prmst=="DiBat"]-0.25
df07$lon2[df07$prmst=="MiFiU"] <- df07$lon[df07$prmst=="MiFiU"]+0.25
#get sampling month
df07$month <- gsub("^(*.*)\\/(*.*)\\/(*.*)$","\\2",df07$date)
#get sampling year
df07$year <- gsub("^(*.*)\\/(*.*)\\/(*.*)$","\\3",df07$date)
year_smpl <- unique(df07$year)
# get start and end month of sampling
mnth_st <- month.abb[min(as.numeric(df07$month))]
mnth_en <- month.abb[max(as.numeric(df07$month))]
# get text string with sampling period
smpl_per <- paste(mnth_st,"-",mnth_en,"-",year_smpl,sep="")
#rename columns that have read count appended
colnames(df07)[grepl("sum_rdcnt\\.",colnames(df07))] <- gsub("sum_rdcnt\\.","",cltm)



#add a column with sampling locations to be able to 
#match between data frames

#install the package that allows for making pit charts in ggplot
if(!require("scatterpie")){
  install.packages("scatterpie", dependencies = TRUE, INSTALL_opts = '--no-lock')
  library("scatterpie")
}
library(scatterpie)

#https://towardsdatascience.com/using-ggplot-to-plot-pie-charts-on-a-geographical-map-bb54d22d6e13
library(ggplot2)

#https://guangchuangyu.github.io/2016/12/scatterpie-for-plotting-pies-on-ggplot/
world <- ggplot2::map_data('world')
jitlvl <- 0.017


library(shadowtext)

# also see : https://github.com/tidyverse/ggplot2/issues/2037
p08 <- ggplot(data = world) +
  geom_map(map=world, aes(map_id=region), fill="grey",
           color="black") +
  #geom_sf(color = "black", fill = "azure3") +
  #geom_point() +
  
  #https://ggplot2.tidyverse.org/reference/position_jitter.html
  # use 'geom_jitter' instead of 'geom_point' 
  scatterpie::geom_scatterpie(aes(x=lon2, y=lat, 
                                  #group = country, 
                                  #r = rws*0.00010), 
                                  r = 0.27), 
                              data = df07, 
                              cols = colnames(df07[,c(clnmm)])) +
  # scale_color_manual(values=c(rep("black",
  #                                 length(unique(df07[,c(clnmm)]))))) +
  #https://stackoverflow.com/questions/54078772/ggplot-scale-color-manual-with-breaks-does-not-match-expected-order
  # set alpha values for color intensity of fill color in point
  scale_fill_manual(values=alpha(
    c(vclr),
    c(0.7)
  ))+
  # add a point for sampling site
  geom_point(data = df07, aes(x=lon,y=lat), col = 'blue', shape=21, size=3, fill="cyan") +
  # add legend for pies
  
  #geom_scatterpie_legend(df07$rws*0.10, x=-10, y=47) +
  # add labels for pies
  geom_text(data = df07, aes(label = prmst, x=lon2, y=lat), col="white") +
  
  # add labels for points
  shadowtext::geom_shadowtext(data = df07, 
                              aes(label = MSTNo, x=lon, y=lat-0.1),
                              col="cyan", bg.colour='blue') +
  #geom_text(aes(label = MSTNo, x=lon, y=lat-0.1), col="cyan") +
  #https://ggplot2.tidyverse.org/reference/aes_colour_fill_alpha.html
  #define limits of the plot
  ggplot2::coord_sf(xlim = c(10, 14),
                    ylim = c(54, 57),
                    expand = FALSE) +
  
  scale_color_manual(values=c(rep("white",
                                  length(unique(df07[,c(clnmm)]))),"red")) +
  # adjust legend position and font
  theme(legend.position = "right",
        #axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 10,face="italic")) +
  # add overall title
  ggtitle(paste("C - fish reads two primersets ", smpl_per,sep=""))

# change labels on axis
p08 <- p08 + xlab("longitude") + ylab("latitude")
# change label for legend
#change the header for the legend on the side, 
#this must be done for both 'fill', 'color' and 'shape', to avoid 
#getting separate legends
p08 <- p08 + labs(fill='species found by eDNA reads')
p08 <- p08 + labs(color='primerset used')

# see the plot
p08


# see this example: https://www.datanovia.com/en/blog/ggplot-title-subtitle-and-caption/
#caption = "Data source: ToothGrowth")
#p08t <- p08 + labs(title = "A")#,
p08t <- p08 + labs(title = paste("A - fish reads two primersets excluding procaryote reads ", smpl_per,sep=""))#,


# ------------- plot Combined figure -------------
library(patchwork)
# set a variable to TRUE to determine whether to save figures
bSaveFigures <- T
#see this website: https://www.rdocumentation.org/packages/patchwork/versions/1.0.0
# on how to arrange plots in patchwork
p <-  p08t +
  plot_layout(nrow=1,byrow=T) + #xlab(xlabel) +
  plot_layout(guides = "collect")# +
  #plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p
#make filename to save plot to
figname08 <- paste0("Fig08_pies_on_map_",smpl_per,"_01.png")

figname08 <- paste(wd00_wd08,"/",figname08,sep="")
if(bSaveFigures==T){
  ggsave(p,file=figname08,
         #width=210,height=297,
         width=297,height=210,
         units="mm",dpi=300)
}

#_______________________________________________________________________________
# plot pies on maps - end
#_______________________________________________________________________________



#make filename to save plot to
figname03 <- paste0("Fig06_stckbarplot_for_",smpl_per,"_01.png")

figname04 <- paste(wd00_wd08,"/",figname03,sep="")
if(bSaveFigures==T){
  ggsave(stbp03,file=figname04,
         #width=210,height=297,
         width=297,height=210,
         units="mm",dpi=300)
}


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

#head(df04,7)








#
#
#
