USE [SEYLabTrainingDatabase] 
GO
/****** Object:  StoredProcedure [dbo].[ [dbo].[usp_Stage_To_Prod_Employee]]    Script Date: 2/4/2018 2:37:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*Testing  
USE [TestLabTrainingDatabase]
GO

DECLARE @RC int
DECLARE @_Logging_FLAG char(1)

Set @_Logging_FLAG  = 'N' 

EXECUTE @RC = [dbo].[usp_Stage_To_Prod_Employee] 
   @_Logging_FLAG
GO

select count(*) from [dbo].[Prod_Employee]

select count(*) from [dbo].[Stage_Employee]

*/

Create PROCEDURE [dbo].[usp_Stage_To_Prod_Employee]
	@_Logging_FLAG CHAR(1) = 'N' 
	
AS




BEGIN
-- Return Value for Stored Proc
    DECLARE @Returns INT
    SET @Returns = 1 


--XACT_ABORT On
SET NOCOUNT ON;
	--  ===================================================================   
	--               Declare Variables
	--  =================================================================== 
	DECLARE @RC INT;
	DECLARE @_TableName VARCHAR(100);
	DECLARE @_PkgName VARCHAR(100);
	DECLARE @_CommandTxt VARCHAR(2000);
	DECLARE @_RunStage VARCHAR(100);
	DECLARE @_ExecStartDT DATETIME;
	DECLARE @_ExecStopDT DATETIME;
	DECLARE @_ExtractRowCnt BIGINT;
	DECLARE @_InsertRowCnt BIGINT;
	DECLARE @_UpdateRowCnt BIGINT;
	DECLARE @_ErrorRowCnt BIGINT;
	DECLARE @_TableInitialRowCnt BIGINT;
	DECLARE @_TableFinalRowCnt BIGINT;
	DECLARE @_TableMaxDateTime DATETIME;
	DECLARE @_SuccessfulProcessingInd CHAR(1);
	DECLARE @_Notes VARCHAR(1000);
	DECLARE @_MasterBatchNumber BIGINT;
	DECLARE @_ChildBatchNumber BIGINT;
	DECLARE @_SQLErrorNumber  INT;
	DECLARE @_SQLErrorLine INT;
	DECLARE @_SQLErrorMessage VARCHAR(1024); 
	DECLARE @_SQLErrorProcedure VARCHAR(1024);
	DECLARE @_SQLErrorSeverity INT; 
	DECLARE @_SQLErrorState INT; 
	DECLARE @_Azure_Input_File VARCHAR(256); 
	DECLARE @_SQL_Statement NVARCHAR(1024); 
	DECLARE @_SQL_Statement_Truncate NVARCHAR(1024);
	--Error checking 
	DECLARE @Err INT;
	DECLARE @ErrPoint VARCHAR(100);

		--  ===================================================================   
	--               Setup 
	--  =================================================================== 

	--  !!!!!!!!!!!!!!!!! Change for each Stored Procedure !!!!!!!!!!!!!!!!!!!!!!!
	--  Change for each package
	SET @_TableName = '[dbo].[Prod_Employee]';
	SET @_PkgName =  '[usp_Stage_To_Prod_Employee]';
	SET @_RunStage = 'Package Start';
	
	--  Starting values
	SET @_CommandTxt = NULL;
	SET @_ExecStartDT = GETDATE();
	SET @_ExecStopDT =  GETDATE();
	SET @_ExtractRowCnt = NULL;
	SET @_InsertRowCnt = NULL;
	SET @_UpdateRowCnt = NULL;
	SET @_ErrorRowCnt = NULL;
	SET @_TableInitialRowCnt = NULL;
	SET @_TableFinalRowCnt = NULL;
	SET @_TableMaxDateTime = NULL;
	SET @_SuccessfulProcessingInd = 'N';
	SET @_Notes = 'Stage to Production ';
	EXECUTE [dbo].[usp_Audit_BatchNumber] @_MasterBatchNumber OUTPUT;
	--Set @_MasterBatchNumber = 33
	SET @_ChildBatchNumber = NULL;
	SET @_SQLErrorNumber = NULL;
	SET @_SQLErrorLine = NULL;
	SET @_SQLErrorMessage = NULL;
	SET @_SQLErrorProcedure = NULL;
	SET @_SQLErrorSeverity = NULL;
	SET @_SQLErrorState = NULL;


--  ================= Error Handle Begin Try ================================ 
	BEGIN TRY  
 
      BEGIN TRANSACTION

	IF (@_Logging_FLAG = 'Y') 
	BEGIN 
	PRINT '[Stage to Prod] - Delete Prod Table.'; 
	PRINT ' '; 
	END; 


	  --  !!!!!!!!!!!!!!!!! Change for each Stored Procedure !!!!!!!!!!!!!!!!!!!!!!!
	  --  ================= Starting Rows Table ================================ 
	 Select  @_TableInitialRowCnt =  Count(*) From [dbo].[Prod_Employee] 



	--  ================= Clear out Table ================================ 
	DELETE  [dbo].[Prod_Employee];


	IF (@_Logging_FLAG = 'Y') 
	BEGIN 
	PRINT '[Copy Table] - Begin Insert.'; 
	PRINT ' '; 
	END; 

	-- Set RunStage
	SET @_RunStage = 'Insert';
 
	--  ================= Insert Into Table ================================
INSERT INTO [dbo].[Prod_Employee]
           (EmployeeID
		   ,FacilityID
           ,OrganizationLevel
           ,SalesPersonFlag
           ,JobTitle
           ,BirthDate
           ,MaritalStatus
           ,Gender
           ,HireDate
           ,SalariedFlag
           ,VacationHours
           ,SickLeaveHours
           ,CurrentFlag
           ,ModifiedDate
           ,NameFull
           ,PayGradeID)
	Select 
		    EmployeeID
		   ,FacilityID
           ,OrganizationLevel
           ,SalesPersonFlag
           ,JobTitle
           ,BirthDate
           ,MaritalStatus
           ,Gender
           ,HireDate
           ,SalariedFlag
           ,VacationHours
           ,SickLeaveHours
           ,CurrentFlag
           ,ModifiedDate
           ,NameFull
           ,PayGradeID
		   From [dbo].[Stage_Employee]

			--  ================= Grab Row Changed ================================ 
		Select @_InsertRowCnt = @@ROWCOUNT
		
		--  !!!!!!!!!!!!!!!!! Change for each Stored Procedure !!!!!!!!!!!!!!!!!!!!!!!
		--  ================= Starting Rows Table ================================ 
	 Select  @_TableFinalRowCnt =  Count(*) From [dbo].[Prod_Employee] 
	
	  --  ================= How long did the insert take ================================ 
	  Set @_ExecStopDT =  getdate()

	-- Set RunStage
	SET @_RunStage = 'Insert Success';
	
		--  ================= Write Successful Input Log Entry ================================  
	EXECUTE @RC = [dbo].[usp_Insert_Audit_ProcessLog_Entry] 
		@_TableName,@_PkgName,@_SQL_Statement,@_RunStage,@_ExecStartDT,@_ExecStopDT,@_ExtractRowCnt,@_InsertRowCnt,
		@_UpdateRowCnt,@_ErrorRowCnt,@_TableInitialRowCnt,@_TableFinalRowCnt,@_TableMaxDateTime,@_SuccessfulProcessingInd,
		@_Notes,@_MasterBatchNumber,@_ChildBatchNumber,@_SQLErrorNumber,@_SQLErrorLine,@_SQLErrorMessage,@_SQLErrorProcedure,
		@_SQLErrorSeverity,@_SQLErrorState; 

  
 

	  --  ================= How long did the Proces take ================================ 
	  Set @_ExecStopDT =  getdate()
	-- Set RunStage
	SET @_RunStage = 'Process Complete';
	SET @_SuccessfulProcessingInd = 'Y';

	-- COMMIT the transaction if successful
	  COMMIT
		--  ================= Write Successful Transform Log Entry ================================  
	EXECUTE @RC = [dbo].[usp_Insert_Audit_ProcessLog_Entry] 
		@_TableName,@_PkgName,@_SQL_Statement,@_RunStage,@_ExecStartDT,@_ExecStopDT,@_ExtractRowCnt,@_InsertRowCnt,
		@_UpdateRowCnt,@_ErrorRowCnt,@_TableInitialRowCnt,@_TableFinalRowCnt,@_TableMaxDateTime,@_SuccessfulProcessingInd,
		@_Notes,@_MasterBatchNumber,@_ChildBatchNumber,@_SQLErrorNumber,@_SQLErrorLine,@_SQLErrorMessage,@_SQLErrorProcedure,
		@_SQLErrorSeverity,@_SQLErrorState; 


	--  ================= End Try ================================  
	END TRY 

	
	--  ================= Begin Catch ================================  
	BEGIN CATCH 
           IF @@TRANCOUNT > 0
         ROLLBACK

		 --Set Error Return Value
         SET @Returns = 0 
	--  ================= Grab values and Write Log Entry ================================
	SELECT 
		@_SQLErrorNumber = ERROR_NUMBER(), 
		@_SQLErrorProcedure = ERROR_PROCEDURE(), 
		@_SQLErrorLine = ERROR_LINE(), 
		@_SQLErrorMessage = ERROR_MESSAGE(), 
		@_SQLErrorSeverity = 16,--ERROR_SEVERITY(),
		@_SQLErrorState = 1,--ERROR_STATE(),
		@_SuccessfulProcessingInd = 'N';


		--Log Error
		SET @_RunStage = 'Process Error';
		--  ================= Send Error Log Entry ================================  
		EXECUTE @RC = [dbo].[usp_Insert_Audit_ProcessLog_Entry] 
		@_TableName,@_PkgName,@_CommandTxt,@_RunStage,@_ExecStartDT,@_ExecStopDT,@_ExtractRowCnt,@_InsertRowCnt,
		@_UpdateRowCnt,@_ErrorRowCnt,@_TableInitialRowCnt,@_TableFinalRowCnt,@_TableMaxDateTime,@_SuccessfulProcessingInd,
		@_Notes,@_MasterBatchNumber,@_ChildBatchNumber,@_SQLErrorNumber,@_SQLErrorLine,@_SQLErrorMessage,@_SQLErrorProcedure,
		@_SQLErrorSeverity,@_SQLErrorState; 

	-- Raise error 
	RAISERROR ('An error occurred within a user transaction. 
				Error Number        : %u 
				Error Message       : %s  
				Affected Procedure  : %s 
				Affected Line Number: %u
				Error Severity      : %u
				Error State         : %u' 
				, 16, 1 
				, @_SQLErrorNumber, @_SQLErrorMessage, @_SQLErrorProcedure, @_SQLErrorLine, @_SQLErrorSeverity, @_SQLErrorState);       
  
	-- ** Error Handling - End Catch **    
	END CATCH;     
	    RETURN @Returns      
	END;
GO
