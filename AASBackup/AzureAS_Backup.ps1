<#
.SYNOPSIS
	This Azure Automation runbook automates Azure Analysis Server database backup to Blob Storage.

.DESCRIPTION
	This runbook leverages the storage configuration of Azure AS within Azure Portal.
	
.PARAMETER DatabaseServerName
	Specifies the server name of the Azure Analysis Services.

.PARAMETER DatabaseName
	Specifies the database name of the Azure Analysis Services.

.PARAMETER StorageAccountName
	Specifies the name of the storage account where backup file will be uploaded

.PARAMETER BlobStorageEndpoint
	Specifies the base URL of the storage account
	
.PARAMETER StorageKey
	Specifies the storage key of the storage account

.PARAMETER BlobContainerName
	Specifies the container name of the storage account where backup file will be uploaded. Container will be created if it does not exist.

.PARAMETER RetentionDays
	Specifies the number of days how long backups are kept in blob storage. Script will remove all older files from container. 
	For this reason dedicated container should be only used for this script.

.PARAMETER CredentialName
	Specifies the credential with admin access to Azure AS

.Created by:
    Bruno Faria - 25/07/2017

#>

param(
    [Parameter(Mandatory = $true)]
    [String]$DatabaseServerName = "asazure://australiasoutheast.asazure.windows.net/...",

    [Parameter(Mandatory = $true)]
    [String]$DatabaseName = "MyDBName",

    [Parameter(Mandatory = $true)]
    [String]$StorageAccountName = "MyStrAccName",

    [Parameter(Mandatory = $true)]
    [String]$BlobStorageEndpoint = "https://...",

    [Parameter(Mandatory = $true)]
    [String]$StorageKey,

	[Parameter(Mandatory = $true)]
    [string]$BlobContainerName = "MyContainerNameForBackups",

	[Parameter(Mandatory = $true)]
    [Int32]$RetentionDays = "7",

    [Parameter(Mandatory = $true)]
    [String]$CredentialName = "MyCredential" 
)

$ErrorActionPreference = 'stop'

try
{
    $servicePrincipalCredential = Get-AutomationPSCredential -Name $credentialName
}
catch {
    if (!$servicePrincipalCredential)
    {
        $ErrorMessage = "Credential $credentialName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

function Delete-Old-Backups([int]$retentionDays, [string]$blobContainerName, $storageContext) {
	Write-Output "Removing backups older than '$retentionDays' days from blob: '$blobContainerName'"
	$isOldDate = [DateTime]::UtcNow.AddDays(-$retentionDays)
	$blobs = Get-AzureStorageBlob -Container $blobContainerName -Context $storageContext
	foreach ($blob in ($blobs | Where-Object { $_.LastModified.UtcDateTime -lt $isOldDate -and $_.BlobType -eq "BlockBlob" })) {
		Write-Verbose ("Removing blob: " + $blob.Name) -Verbose
		Remove-AzureStorageBlob -Blob $blob.Name -Container $blobContainerName -Context $storageContext
	}
}

Write-Verbose "Starting database backup" -Verbose

$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

$BackupFileName = $DatabaseName + "_" + (Get-Date).ToString("yyyyMMdd") + ".abf"
$XMLAQuery = '{ "backup": { "database": "'+$DatabaseName+'", "file": "'+$BackupFileName+'", "allowOverwrite": true, "applyCompression": true } }'
	
Invoke-ASCmd -Server $DatabaseServerName -Query:$XMLAQuery -Credential $servicePrincipalCredential

Delete-Old-Backups -retentionDays $RetentionDays -storageContext $StorageContext -blobContainerName $BlobContainerName

Write-Verbose "Database backup script finished" -Verbose