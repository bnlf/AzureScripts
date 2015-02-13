workflow vm-start
{
    # Parametros de inicializaçãoo
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $AzureConnectionName       
    )
 
    # Pega a variável de conexão previamente criada na aba Ativos do Azure Automation
    $AzureConn = Get-AutomationConnection -Name $AzureConnectionName
    if ($AzureConn -eq $null)
    {
        throw "Could not retrieve '$AzureConnectionName' connection asset. Check that you created this first in the Automation service."
    }
    
    # Pega a variável de certificado previamente criado na aba Ativos do Azure Automation
    $Certificate = Get-AutomationCertificate -Name $AzureConn.AutomationCertificateName
    if ($Certificate -eq $null)
    {
        throw "Could not retrieve '$AzureConn.AutomationCertificateName' certificate asset. Check that you created this first in the Automation service."
    }
    
    # Seta a configuração da subscription do Azure
    Set-AzureSubscription -SubscriptionName $AzureConnectionName -SubscriptionId $AzureConn.SubscriptionID -Certificate $Certificate
    Select-AzureSubscription -SubscriptionName $AzureConnectionName
     
	# Este bloco pode ser aprimorado. Pode ser utilizado uma lista de máquinas ou o código pode ser replicado diversas vezes para incluir mais do que uma máquina no script
    # Nome e CloudService da VM do Azure
    $vmName = 'bnlf-demo1'
    $svcName = 'bnlf-demo1'
    
	# Pega máquina do Azure
    $vm = Get-AzureVM -ServiceName $svcName -Name $vmName
 
	# Se parado e dealocado, inicia a VM
    if ( $vm.InstanceStatus -eq 'StoppedDeallocated' ) {
        Start-AzureVM -ServiceName $vm.ServiceName -Name $vm.Name
    }

}