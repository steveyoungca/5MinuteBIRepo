


-- ========================================================================================
-- Create User as DBO template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ========================================================================================
-- For login <login_name, sysname, login_name>, create a user in the database

--use [Master]   -- Note "Use  DB" is not avalable in SQL Azure DB
--Remember complexity requirements on your password
CREATE LOGIN  RunBookUserAccount WITH password='password!!!';

CREATE USER RunBookUserAccount
	FOR LOGIN RunBookUserAccount
	WITH DEFAULT_SCHEMA = dbo
GO

-- Add user to the database owner role
EXEC sp_addrolemember N'db_owner', N'RunBookUserAccount'
GO


-- ========================================================================================
--          Another Example, depending on your requirements
-- ========================================================================================
 

EXEC sp_droprolemember 'db_owner', 'RunBookUserAccount';  
GO

EXEC sp_addrolemember 'db_datareader', 'RunBookUserAccount';

GO

EXEC sp_addrolemember 'db_datawriter', 'RunBookUserAccount'; 
GO