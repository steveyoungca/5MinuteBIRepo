##
##  R SCRIPT: R_With_SQL_AzureConnectivity_Share.R
## 
##  Description: Grab a table in AzureSQL as a Data Frame & 
##               run R Summary Statistics, Missing Values on each column
##               and out put to CSV files
## 
##  Parameters : none
##
##  License: MIT
##
##  GitHub Repository: https://github.com/steveyoungca/R_With_SQL_Azure_Connectivity
## 
##  Documentation on the write table package 
##  https://stat.ethz.ch/R-manual/R-devel/library/utils/html/write.table.html 
##  Documentaion on the RODBC Library
##  https://www.rdocumentation.org/packages/RODBC
##
##
##  Date					    Developer		  	Action
##  ---------------------------------------------------------------------
##  Sept 23, 2017			Steve Young			Initial Version
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

## On Mac I had to run "sudo gcc" at a command prompt as the xcode install
##      set gcc to require me to agree to the licence.  I then went back to 
##      RStudio and typed the install.packages("RODBC")
##    Then had to run the following commands:  brew install unixodbc
##    The RODBC package then installed and all was fine.
##
##br
#Install the RODBC package the first run
#install.packages("RODBC")

library(RODBC)
sqlServer <- "<DBServer>database.windows.net"  #Enter Azure SQL Server
sqlDatabase <- "AdventureWorksLT"                   #Enter Database Name
sqlUser <- "<UID>"                          #Enter the SQL User ID
sqlPassword <- "<PWD>"                     #Enter the User Password
#sqlDriver <- "SQL Server"                     #Leave this Drive Entry (Windows)
sqlDriver <- "{ODBC Driver 13 for SQL Server}"                     #Used this drive on my Mac
##See Documentation for Installing the Driver on a MAC

connectionStringSQL <- paste0(
  "Driver=", sqlDriver, 
  ";Server=", sqlServer, 
  ";Database=", sqlDatabase, 
  ";Uid=", sqlUser, 
  ";Pwd=", sqlPassword,
  ";Encrypt=yes",
  ";Port=1433")


#Enter the SQL Query into the dataframe variable
sqlQuery <- "SELECT * from [SalesLT].[SalesOrderDetail]"



##  ===================================================================
##               Connect, Grab Data to a data frame and Close
##  =================================================================== 
conn <- odbcDriverConnect(connectionStringSQL)
sqlDataFrame <- sqlQuery(conn, sqlQuery)
close(conn) # Do not forget to close the connection, we are SQL you know


##    What is the structure
str(sqlDataFrame)

##    What is the summary
summary(sqlDataFrame)

##    What is the NA values in the table

##  ===================================================================
##               Write the summary to a CSV file
##             Change to match file name and location
##  =================================================================== 


write.table(summary(sqlDataFrame), file = "SummaryCustomers.csv", append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

write.table(apply(is.na(sqlDataFrame),2,sum), file = "SummaryCustomers_NA.csv", append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

write.table(colSums(df != 0), file = "SummaryCustomers_0.csv", append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

#Clean Up the R Environment when finished
rm(list = ls())   