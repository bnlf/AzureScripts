#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name "Automation"
if(!$Cred) {
    Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
}

#$ClientSecret = ""
#$ApplicationId = ""
#$SubscriptionId = ""

#New PSCredential Object
#$secpasswd = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
#$mycreds = New-Object System.Management.Automation.PSCredential ($ApplicationId , $secpasswd)

#Login to subscription
Login-AzureRmAccount -Credential $Cred -SubscriptionId $SubscriptionId

#Get storage context
#New-AzureRmSqlDatabaseExport -ResourceGroupName "" -ServerName "" -DatabaseName "" -StorageKeyType "StorageAccessKey" -StorageKey "" -StorageUri "" -AdministratorLogin $ApplicationId -AdministratorLoginPassword $secpasswd -AuthenticationType "AdPassword"

Write-Warning –Message "This is a warning message."