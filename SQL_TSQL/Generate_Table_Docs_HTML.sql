/*
  TSQL SCRIPT: Generate_Table_Docs_HTML.sql
 
  Description: Loop through tables in a database and produce an HTML Doc
 
  Parameters : none

  License: MIT

  GitHub Repository: https://github.com/steveyoungca/SQL_TSQL_Document.git
 
  Date					Developer			Action
  ---------------------------------------------------------------------
  Jan 15, 2015			Steve Young			Initial Version
  Sept 11, 2017     Steve Young     Include BootStrap and VSCode project tester
  Sept 13, 2017			Steve Young			Revisions and GitHub publish
 
  TODO:
	1. Remove the header lines that comes thorugh in the select. 
	
  Testing:
  -------------------------------------------------------------
    1. Select the tables in scope for the documentation
		Select distinct Table_name
		FROM INFORMATION_SCHEMA.COLUMNS
		--where table_name not like '%old' 
		--where table_name = 'Customers'
		--where table_name like 'Clean%'
		order by Table_name  
		
	Execute:  
		1. Load the .SQL file into SSMS
		2. Change the where clause 
 */
/*                Settings & Declarations
=================================================================== */
Set nocount on
DECLARE @TableName nvarchar(50)
--Variable to house the current table name
--User Table to house the table list
DECLARE @userTables TABLE(
  RowID int not null identity(1,1) primary key,
  Tablename varchar(50) NOT NULL
);
/*                Grab the tables for the loop
				  Change based on your requirements
=================================================================== */
--  Customise the where based on your requirements
--  Limit to one table while testing is the current setup
INSERT INTO @userTables
  ([Tablename])
Select distinct Table_name
FROM INFORMATION_SCHEMA.COLUMNS
--where table_name not like '%Clean' 
--where table_name like 'Clean%'
--where table_name = 'Clean_LeapKnee01'
order by Table_name
-- Order by name
/*                Output the HTML header
=================================================================== */
--	These are current as of script writing
--	BootStrap is the base formats based on default css for bootstrap
--Select * from @userTables   -- uncomment for debugging
PRINT '<!DOCTYPE html>'
PRINT '<html>'
PRINT '<head>'
PRINT '    <meta charset="utf-8" />'
PRINT '      <meta name="viewport" content="width=device-width, initial-scale=1">'
PRINT '      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">'
PRINT '      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>'
PRINT '      <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>'
PRINT '      <style>'
PRINT '       .table-condensed{font-size: 10px; table-layout: fixed;}'
PRINT '      </style>'
PRINT '    <title></title>'
PRINT '</head>'
PRINT '<body>'
/*                Simple loop based on the RowID of the table
=================================================================== */
Declare @i int
select @i = min(RowID)
from @userTables
declare @max int
select @max = max(RowID)
from @userTables
--Loop Begin
while @i <= @max begin
  --Grab the current table
  Set @TableName = (select Tablename
  from @userTables
  where RowID = @i)
  --do some stuff
  -- Print out the section header
  -- Bootstrap elements are added here also
  PRINT '<br>'
  PRINT '<br>'
  PRINT '<div class="container">'
  PRINT '  <h2>' + @TableName + '</h2>'
  PRINT '  <br>'
  PRINT '  <table class="table table-striped table-condensed" id="sqltable">'
  PRINT '  <thead>'
  PRINT '     <tr>'
  PRINT '     <th style="width:5%"><b>POS</b></th>'
  PRINT '     <th style="width:20%"><b>COLUMN NAME</b></th>'
  PRINT '     <th style="width:10%"><b>DATA TYPE</b></th>'
  PRINT '     <th style="width:5%"><b>MAX LENGTH</b></th>'
  PRINT '     <th style="width:5%"><b>IS_NULL</b></th>'
  PRINT '     <th style="width:5%"><b>DEFAULT</b></th>'
  PRINT '     <th style="width:20%"><b>Notes</b></th></tr>'
  PRINT '  </thead>'
  -- Setup and print the out the details of the table.
  PRINT '<tbody>'
  PRINT ' <tr>'
  SELECT '  <td>' + isnull(ltrim(rtrim(ORDINAL_POSITION)),'NULL') + '</td>', '<td>' + isnull(rtrim(ltrim(COLUMN_NAME)),'NULL') + '</td>', '<td>' + isnull(rtrim(ltrim(DATA_TYPE)),'NULL') + '</td>', '<td>' + isnull(rtrim(ltrim(CHARACTER_MAXIMUM_LENGTH)),'NULL') + '</td>', '<td>' + isnull(rtrim(ltrim(IS_NULLABLE)),'NULL') + '</td>', '<td>' + isnull(rtrim(ltrim(COLUMN_DEFAULT)),'NULL') + '</td>', '<td></td></tr>'
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE   
  TABLE_NAME = @TableName
  ORDER BY 
  ORDINAL_POSITION ASC;
  -- close the table
  PRINT '  </tr></table>'
  PRINT '</tbody>'
  PRINT '</table>'
  PRINT '</div>'
  -- Increment the counter
  set @i = @i + 1
-- Loop back
end
--Close out the table and web
PRINT '</body></HTML>'
