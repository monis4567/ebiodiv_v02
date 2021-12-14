# /////////////////////////////////////////////////////////////////////////////////////////
# function prefilter
# /////////////////////////////////////////////////////////////////////////////////////////
# Filter data OTU-wise according to upper and lower margin set, and taxa to exclude
prefilter <- function(tableID, upper_margin=0, lower_margin=2, remove=c("uncultured", "environmental")) {
  new_tableID <- tableID[0,] # prepare filtered matchlist
  tableID <- tableID[!tableID$staxid == "N/A",]
  ids <- names(table(tableID$qseqid))
  i=1
  for (name in ids) {
    test <- tableID[tableID$qseqid == name,] # select all lines for a query
    if (nchar(remove[1])>0) {
      test2 <- test
      for (rm in 1:length(remove)) {
        test2 <- test2[!grepl(remove[rm], test2$ssciname,ignore.case = TRUE),]
      }
      if (nrow(test2) > 1) {test <- test2}
    }
    
    max <- max(test$pident)
    upper <- max-upper_margin
    lower <- max-lower_margin
    test <- test[which(test$pident >= lower),] # select all lines for a query
    test$margin <- "lower"
    test[test$pident >= upper,"margin"] <- "upper"
    
    new_tableID = rbind(new_tableID,test) # add this row to the filtered tableID
    i=i+1
  }
  return(new_tableID)
}

# /////////////////////////////////////////////////////////////////////////////////////////
# function taxid_replace
# /////////////////////////////////////////////////////////////////////////////////////////
# new function to find and replace outdated taxids
taxid_replace<-function(tableID,tableIDreplacements,printlist=F){
  # Replace old tax ids with new ones if they have a match in mergedtaxids dataframe #CKF 
  tableID <- tableID %>%
    mutate(OldTaxID=as.integer(staxid)) %>%  # Making an extra column on pf, same as staxid but with a new name so it can match 
    left_join(tableIDreplacements, by="OldTaxID")  # now we can join with MergedTaxIDs using the oldtaxid column
  
  # Print which IDs are being changed 
  tableID_changedID <- tableID %>%
    filter(!is.na(NewTaxID))
  
  # if you really want to see a list of all the items with changed taxid, 
  # then set the printlist parameter to TRUE
  if(printlist){
    if(nrow(tableID_changedID)>0){
      for (i in 1:nrow(tableID_changedID)) {
        print(paste("Warning:", tableID_changedID$qseqid[i], " has an outdated taxid. Overwriting outdated taxid:", 
                    tableID_changedID$OldTaxID[i], "to new taxid:", tableID_changedID$NewTaxID[i]),sep=" ")
      }
    }else{
      print("No taxids were updated.")
    }
  }
  
  tableID <- tableID %>%
    mutate(staxid=ifelse(is.na(NewTaxID), staxid, NewTaxID)) %>% # If there is no match, then staxid stays the same,
    # otherwise it takes the id in NewTaxID
    dplyr::select(-c(OldTaxID, NewTaxID)) # Now remove the two columns added to the dataframe, no longer needed 
  
  return(tableID)
}

# /////////////////////////////////////////////////////////////////////////////////////////
# function get_classification
# /////////////////////////////////////////////////////////////////////////////////////////
get_classification <- function(tableID,Start_from=1,sleep_interval=60,timeout_limit=60){
  require(taxizedb)
  all_staxids <- names(table(tableID$staxid[tableID$margin=="upper"])) # get all taxids for table
  all_classifications <- list() # prepare list for taxize output
  o=length(all_staxids) # number of taxids
  
  # Start_from = 1 # change if loop needs to be restarted due to time-out
  # sleep_interval = 60 # time to sleep (sec) before new attempt after failed taxize::classification 
  
  wrong_taxid_matches <- c()
  remove_entries <- c()
  
  
  print(paste0("Step 1 of 3: processing: ", o , " taxids")) 
  
  #Get ncbi classification of each entry
  for (cl in Start_from:o) {

    attempts<- 0
    max_attempts <- 10
    curr_staxid <- all_staxids[cl]
    cat(paste0("Working on staxid[",cl,"/",o,"] ", curr_staxid,"\n"))
    
    repeat{
      attempts <- attempts + 1
      cat(paste0("     attempt ",attempts))
      
      start_time <- Sys.time()
      tax_match <- NULL
      tryCatchResult <- tryCatch(                     # Using tryCatch() function
        
        expr = {                    # Setting up the expression
          #fetch the classification information
          tax_match <- taxize::classification(curr_staxid, db = "ncbi")   # AGR
          ""
        },
        
        error = function(e){        # Error message that should be returned
          cat(paste0(" ...error: ",e$message,"\n"))
          return(e$message)
        }) # end of tryCatch
      
      # # just to see the TryCatch result in case there is an error
      # if (!is.null(tax_match)){
      #       print("Here is the result from TrCatch")
      #       print(tryCatchResult)
      #       }
      
      #The if test to check whether the repeat function should be stopped
      # if a tax match was found, then change success to TRUE
      
      doSleep <- FALSE
      if (!is.null(tax_match)) {
        # the function was successful
        cat(" ...successful!\n")
        break
      }else if (attempts >= max_attempts) {
        # too many attempts - stop and add this taxid to the "wrong" list
        cat(paste0("tried finding tax_match ", attempts, " times, but does not exist\n"))
         break
      }else{
        # unsuccessful attempt
        time_elapsed <- Sys.time() - start_time
        if(time_elapsed<timeout_limit){
          # the error occurred within timeout limit
          if(grepl("HTTP",tryCatchResult)==TRUE){
            # HTTP error e.g. 429
            cat("HTTP error\n")
            doSleep <- TRUE
          }else{
            # it was likely a "1770542 error" so no need to retry
            cat("Skipping this taxid\n")
            break
          }
        }else{
          # the error was likely a timeout
          cat("Looked like a timeout\n")
          doSleep <- TRUE
        }
      }
      if(doSleep==TRUE){
        #- sleep before trying again
        cat(paste0("Trying again in ", sleep_interval, " sec.\n"))
        Sys.sleep(sleep_interval)
      }
      
    } # end of repeat
    
    #check if tax_match is wrong
    if (is.null(tax_match)) {
      wrong_taxid_matches <- c(wrong_taxid_matches,curr_staxid)
    } else {
      all_classifications[length(all_classifications)+1] <- tax_match
    }        
    
  } # end of loop (cl in Start_from:o)
  
  #Construct a taxonomic path from each classification
  output <- data.frame(staxid=character(),kingdom=character(), phylum=character(),class=character(),order=character(),family=character(),genus=character(),species=character(), stringsAsFactors=FALSE)
  totalnames <- length(all_classifications)
  
  ## - 1 ## this is if you have one NA, would run on test file, but not necessarily on other files with more NAs
  for (curpart in seq(1:totalnames)) {
    print(paste0("step 2 of 3: progress: ", round(((curpart/totalnames) * 100),0) ,"%")) # make a progress line
    currenttaxon <- all_classifications[curpart][[1]]
    if (nchar(currenttaxon[1]) > 0) {
      spec <- all_staxids[curpart]
      output[curpart,"kingdom"] <- currenttaxon[which(currenttaxon$rank == "kingdom"),"name"][1]
      output[curpart,"phylum"] <- currenttaxon[which(currenttaxon$rank == "phylum"),"name"][1]
      output[curpart,"class"] <- currenttaxon[which(currenttaxon$rank == "class"),"name"][1]
      output[curpart,"order"] <- currenttaxon[which(currenttaxon$rank == "order"),"name"][1]
      output[curpart,"family"] <- currenttaxon[which(currenttaxon$rank == "family"),"name"][1]
      output[curpart,"genus"] <- currenttaxon[which(currenttaxon$rank == "genus"),"name"][1]
      output[curpart,"species"] <- currenttaxon[which(currenttaxon$rank == "species"),"name"][1]
      output[curpart,"staxid"] <-  spec # add that row to the filtered IDtable
    }
  }
  taxonomic_info <- merge(tableID,output,by = "staxid", all=TRUE)
  taxonomic_info$species[is.na(taxonomic_info$species)] <- taxonomic_info$ssciname[is.na(taxonomic_info$species)]
  return(list(taxonomic_info,wrong_taxid_matches))  
}


# /////////////////////////////////////////////////////////////////////////////////////////
# function evaluate_classification
# /////////////////////////////////////////////////////////////////////////////////////////

# Function3
# Function for evaluating the taxonomic assignment of each OTU. 
#All hits within the upper margin are used in the evaluation weighted by their evalue, 
#so that suboptimal matches have a lower weight. All hits within the lower margin are put
# into the output (but not used for evaluating classification)
evaluate_classification <- function(classified) {
  require(tidyr)
  require(dplyr)
  ids <- names(table(classified$qseqid))
  i <- 1
  for (name in ids) {
    print(paste0("last step: progress: ", round(((i/length(ids)) * 100),0) ,"%")) # make a progressline
    test <- classified[which(classified$qseqid == name),]
    test2 <- test %>% filter(margin == "upper")
    test2$score <- 100*(1/test2$evalue)/sum(1/test2$evalue)  # HER BEREGSES SCOREN FOR ALLE MATCHES PER OTU
    test4 <- test2 %>% filter(margin == "upper") %>%
      dplyr::select(margin,qseqid,sgi,sseq,staxid,pident,score,qcovs,kingdom,phylum,class,order,family,genus,species) %>% 
      group_by(qseqid,kingdom, phylum,class,order,family,genus,species) %>% 
      mutate(species_score=sum(score)) %>% 
      group_by(qseqid,kingdom, phylum,class,order,family,genus) %>% 
      mutate(genus_score=sum(score)) %>%
      group_by(qseqid,kingdom, phylum,class,order,family) %>% 
      mutate(family_score=sum(score))%>%
      group_by(qseqid,kingdom, phylum,class,order) %>% 
      mutate(order_score=sum(score)) %>%
      group_by(qseqid,kingdom, phylum,class) %>% 
      mutate(class_score=sum(score)) %>%
      group_by(qseqid,kingdom, phylum) %>% 
      mutate(phylum_score=sum(score)) %>%
      group_by(qseqid,kingdom) %>% 
      mutate(kingdom_score=sum(score)) %>% ungroup() %>%
      arrange(-kingdom_score,-phylum_score,-class_score,-order_score,-family_score,-genus_score,-species_score)
    test3 <- test4 %>% slice(1)
    test5 <- test4 %>% distinct(qseqid,sgi,sseq,pident,qcovs,kingdom,phylum,class,order,family,
                                genus,species,sseq,kingdom_score,phylum_score,class_score,order_score,family_score,genus_score,species_score) 
    string1 <- test %>% dplyr::select(species,pident) %>% 
      distinct(species,pident) %>% arrange(-pident) %>% t()
    string2 <- toString(unlist(string1))
    test3$alternatives <- string2
    if (i == 1){result <- test3} else {
      result <- rbind(result,test3)
    }
    if (i == 1){result2 <- test2} else {
      result2 <- rbind(result2,test2)
    }
    if (i == 1){result3 <- test5} else {
      result3 <- rbind(result3,test5)
    }
    i=i+1
  }
  total_result <- list(taxonon_table = result, all_taxa_table=result2, all_taxa_table_summed=result3)
  return(total_result)
}

