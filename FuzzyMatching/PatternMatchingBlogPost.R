##
##  R SCRIPT: Matching_Customers_Initial_Examination_Project.R
## 
##  Description:  
##     https://www.r-bloggers.com/fuzzy-string-matching-a-survival-skill-to-tackle-unstructured-information/            
##               
## 
##  Parameters : none
##
##  License: 
##
##  GitHub Repository: None
## 
##  Documentation on the write table package 
##  https://stat.ethz.ch/R-manual/R-devel/library/utils/html/write.table.html 
##  Documentaion on the RODBC Library
##  https://www.rdocumentation.org/packages/RODBC
##
##
##  Date					    Developer		  	Action
##  ---------------------------------------------------------------------
##  Jan 12, 2018 			Steve Young			Initial Version for blog
##   
## 
##  TODO:
##	1. 
##	
##  Testing:
##  -------------------------------------------------------------
##    1. 
##		
##	Execute:  
##		1. 


##  ===================================================================
##               Settings & Declarations
##  =================================================================== 


  #Clean Up the R Environment when finished
  rm(list = ls()) 

  #Install the package for working with data frames
  install.packages("dplyr") 
  library(dplyr)
  
  
  ##############################################################################################
  #                Load in the customers from  the Dim Table
  ##############################################################################################
  
  source1.devices<- read.table("c:/files/source/Product_DimTable.csv",quote = "\"",  header = TRUE, sep = ",", fill = TRUE)

  ##############################################################################################
  #                Customer Compare From the Access Table
  ##############################################################################################
  
  source2.devices<- read.table("c:/files/source/Product_Access.csv",quote = "\"",  header = TRUE, sep = ",", fill = TRUE)
  

  ##############################################################################################
  #                Make sure each of these values are a characters
  ##############################################################################################
  source1.devices$name<-as.character(source1.devices$name)
  source2.devices$name<-as.character(source2.devices$name)
  
  
  ##############################################################################################
  #                See Juan Bernabe's blog post for the jucy bits :)  
  ##############################################################################################
  # It creates a matrix with the Standard Levenshtein distance between the name fields of both sources
  dist.name<-adist(source1.devices$name,source2.devices$name, partial = TRUE, ignore.case = TRUE)
  
  # We now take the pairs with the minimum distance
  min.name<-apply(dist.name, 1, min)
  
  match.s1.s2<-NULL  
  for(i in 1:nrow(dist.name))
  {
    s2.i<-match(min.name[i],dist.name[i,])
    s1.i<-i
    match.s1.s2<-rbind(data.frame(s2.i=s2.i,s1.i=s1.i,s2name=source2.devices[s2.i,]$name, s1name=source1.devices[s1.i,]$name, adist=min.name[i]),match.s1.s2)
  }
  
  
  # Inspect the results
  View(match.s1.s2)
  
  #Write the results to a csv file for examination in Excel
  write.table(match.s1.s2, file = "c:/files/source/results.csv", append = FALSE, quote = TRUE, sep = ",",
              eol = "\n", na = "NA", dec = ".", row.names = TRUE,
              col.names = TRUE, qmethod = c("escape", "double"),
              fileEncoding = "")