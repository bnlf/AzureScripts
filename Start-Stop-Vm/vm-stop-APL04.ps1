workflow vm-stop-APL04
{
    # Parametros de inicializa��o
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $AzureConnectionName       
    )
 
    # Pega a vari�vel de conex�o previamente criada na aba Ativos do Azure Automation
    $AzureConn = Get-AutomationConnection -Name $AzureConnectionName
    if ($AzureConn -eq $null)
    {
        throw "Could not retrieve '$AzureConnectionName' connection asset. Check that you created this first in the Automation service."
    }
    
    # Pega a vari�vel de certificado previamente criado na aba Ativos do Azure Automation
    $Certificate = Get-AutomationCertificate -Name $AzureConn.AutomationCertificateName
    if ($Certificate -eq $null)
    {
        throw "Could not retrieve '$AzureConn.AutomationCertificateName' certificate asset. Check that you created this first in the Automation service."
    }
    
    # Seta a configura��o da subscription do Azure
    Set-AzureSubscription -SubscriptionName $AzureConnectionName -SubscriptionId $AzureConn.SubscriptionID -Certificate $Certificate
    Select-AzureSubscription -SubscriptionName $AzureConnectionName
     
	# Este bloco pode ser aprimorado. Pode ser utilizado uma lista de m�quinas ou o c�digo pode ser replicado diversas vezes para incluir mais do que uma m�quina no script
    # Nome e CloudService da VM do Azure
    $vmName = 'SRV-APL04'
    $svcName = 'srv-centralar-apl'
    
	# Pega m�quina do Azure
    $vm = Get-AzureVM -ServiceName $svcName -Name $vmName
 
	# Se pronto, para e dealoca a VM
    if ( $vm.InstanceStatus -eq 'ReadyRole' ) {
        Stop-AzureVM -ServiceName $vm.ServiceName -Name $vm.Name -Force
    }

}