# Method 1

$ClientSecret = ""
$ApplicationId = ""
$SubscriptionId = ""

#New PSCredential Object
$secpasswd = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ApplicationId , $secpasswd)

#Login to subscription
Login-AzureRmAccount -Credential $mycreds -SubscriptionId $SubscriptionId

#Export Database
New-AzureRmSqlDatabaseExport -ResourceGroupName "<RG>" -ServerName "<SQLSERVERNAME>" -DatabaseName "<DATABASENAME>" -StorageKeyType "StorageAccessKey" -StorageKey "<STRKEY>" -StorageUri "<URITOFILE>" -AdministratorLogin "<DBLOGIN>" -AdministratorLoginPassword "<DBPASS>"

# Method 2

# Authenticate to Azure with service principal and certificate, and set subscription
$connectionAssetName = "AzureRunAsConnection"
$conn = Get-AutomationConnection -Name $ConnectionAssetName

Add-AzureRmAccount -ServicePrincipal -Tenant $conn.TenantID -ApplicationId $conn.ApplicationId -CertificateThumbprint $conn.CertificateThumbprint -ErrorAction Stop | Write-Verbose
Set-AzureRmContext -SubscriptionId $conn.SubscriptionId -ErrorAction Stop | Write-Verbose

#Export Database
New-AzureRmSqlDatabaseExport -ResourceGroupName "<RG>" -ServerName "<SQLSERVERNAME>" -DatabaseName "<DATABASENAME>" -StorageKeyType "StorageAccessKey" -StorageKey "<STRKEY>" -StorageUri "<URITOFILE>" -AdministratorLogin "<DBLOGIN>" -AdministratorLoginPassword "<DBPASS>"
