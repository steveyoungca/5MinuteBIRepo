workflow RunStoredProcAzureWEmail
{
    [cmdletbinding()]
    param
    (
        # Fully-qualified name of the Azure DB server
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $SqlServerName = "<DBSERVER>.database.windows.net",

        # Name of database to connect and execute against
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $DBName = "<DBNAME>",

        # Name of stored procedure to be executed
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $StoredProcName = "usp_Stage_To_Prod_Employee",

        # Credentials for $SqlServerName stored as an Azure Automation credential asset
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential ,

        # Subject for the email
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $SubjectText = "Running of usp_Stage_To_Prod_Employee through runbook",

       # PowerShell Credentials for the Secure SMTP Service
	    [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $AzureOrgIdCredentialString = "RunEmail", 
        
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $BodyText = "This is an automated mail send from Azure Automation relaying mail using Office 365.",
                        
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $ToUser ="<To User or Group in Operations>"
    )
    inlinescript
    {
        Write-Output "========================================================================"
        Write-Output “JOB STARTING”
        Write-Output "========================================================================"

        # Setup variables
        $ServerName = $Using:SqlServerName
        $UserId = $Using:Credential.UserName
        $Password = ($Using:Credential).GetNetworkCredential().Password
        $DB = $Using:DBName
        $SP = $Using:StoredProcName
        
        #Email Variables
        $Subject = $Using:SubjectText 
        $AzureOrgIdCredential = $Using:AzureOrgIdCredentialString
        $Body = $Using:BodyText
        $To = $Using:ToUser
        $From = "<RunBookEmailCred Email Address>.onmicrosoft.com"




        Try {
            #---------------------------------------------------------------------------------
            # Get the PowerShell Credentials from Azure Automation account assets (For Email)
            #---------------------------------------------------------------------------------               
                # Get the PowerShell credential and prints its properties
                $Cred = Get-AutomationPSCredential -Name $AzureOrgIdCredential
                if ($Cred -eq $null)
                {
                    Write-Output "Credential entered: $AzureOrgIdCredential does not exist in the automation service. Please create one `n"   
                }
                else
                {
                    $CredUsername = $Cred.UserName
                    $CredPassword = $Cred.GetNetworkCredential().Password
                    Write-Output "We have the Credential Username: $CredUsername"
                }

            # Create and Open the PowerShell Connection to the Database
            $DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
            $DatabaseConnection.ConnectionString = “Data Source = $ServerName; Initial Catalog = $DB; User ID = $UserId; Password = $Password;”
            $DatabaseConnection.Open();
           
            Write-Output “Connection to the Database is open”

            # Create & Define command and query text
            $DatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
            $DatabaseCommand.CommandType = [System.Data.CommandType]::StoredProcedure
            $DatabaseCommand.Connection = $DatabaseConnection
            $DatabaseCommand.CommandText = $SP
            
            #Set up for return value that will drive the success or failur from the stored Procedure.
            $DatabaseCommand.Parameters.Add("@ReturnValue", [System.Data.SqlDbType]"Int") 
            $DatabaseCommand.Parameters["@ReturnValue"].Direction = [System.Data.ParameterDirection]"ReturnValue"

            Write-Output “Excuting the Query: $StoredProcName”
           
            # Execute the query
            $OUT = $DatabaseCommand.ExecuteNonQuery()   | out-null

            Write-Output $OUT
            #Changed Code
            $returnValue = $DatabaseCommand.Parameters["@ReturnValue"].Value
            Write-Output "Return Value = $ReturnValue "

            if($ReturnValue -eq $null -or $ReturnValue -eq 0)
            {
                Write-Output "An Error Occured"
                $Subject = "Mail sent from Azure Automation using Office 365- $SP = Error in SP"
            } 
            else
            {
                Write-Output "Success"
                $Subject = "Mail sent from Azure Automation using Office 365- $SP = Successful"
            }
            Write-Output " TRY SECTION COMPLETED”
            Write-Output "========================================================================"
 
 
            # ---------------------------------------------------------------------------------
            # This section sends a mail using Office 365 secure SMTP services.  
            # ---------------------------------------------------------------------------------
            #$Subject = "Mail sent from Azure Automation using Office 365- $SP = Successful"
            Send-MailMessage -To $To -Subject $Subject  -Body $Body -UseSsl -Port 587 -SmtpServer 'smtp.office365.com' -From $From -Credential $Cred
              
            Write-Output "Success Mail is now sent `n"
            Write-Output " TRY Really Completed - Email sent `n”
            Write-Output "========================================================================"
        }
        Catch {
            # ---------------------------------------------------------------------------------
            # This section sends a mail using Office 365 secure SMTP services.  
            # ---------------------------------------------------------------------------------
            $Subject = "Mail sent from Azure Automation using Office 365- $SP = Failure"
            $Body = $_.Exception


                 Send-MailMessage -To $To -Subject $Subject  -Body $Body -UseSsl -Port 587 -SmtpServer 'smtp.office365.com' -From $From -Credential $Cred
              
                    Write-Output "Failure  Mail is now sent `n"
                    Write-Output "-------------------------------------------------------------------------"
                Write-Error -Message $_.Exception
                Throw $_.Exception

        }

        Finally{
            # Close connection to DB
            $DatabaseConnection.Close()
            Write-Output “CONNECTION CLOSED”
            Write-Output “JOB COMPLETED”
            Write-Output "-------------------------------------------------------------------------"
        }

    }

}
