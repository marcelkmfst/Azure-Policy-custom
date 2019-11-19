  ########### Runbook by MK to start Azure Firewall instance (change from deallocate) 
Param
(
  [Parameter (Mandatory= $true)]
  [String] $AzureFirewall,

  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallResourceGroup,

  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallPIP,


  
  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallVNETName,

  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallVNETResourceGroup,

  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallPIPResourceGroup
  )

import-module Az.Network
Import-Module Az.Accounts
Import-Module Az.Automation
Import-Module Az.Compute


$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


# Start a firewall

$azfw = Get-AzFirewall -Name $AzureFirewall -ResourceGroupName $AzureFirewallResourceGroup
$vnet = Get-AzVirtualNetwork -ResourceGroupName $AzureFirewallVNETResourceGroup -Name $AzureFirewallVNETName
$publicip = Get-AzPublicIpAddress -Name $AzureFirewallPIP -ResourceGroupName $AzureFirewallPIPResourceGroup
$azfw.Allocate($vnet,$publicip)
Set-AzFirewall -AzureFirewall $azfw