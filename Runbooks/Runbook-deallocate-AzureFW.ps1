####### Runbook by MK to set AzureFW to deallocated
Param(
  [Parameter (Mandatory= $true)]
  [String] $AzureFirewall,

  [Parameter (Mandatory= $true)]
  [String] $AzureFirewallResourceGroup
)

import-module Az.Network
Import-Module Az.Accounts
Import-Module Az.Automation
Import-Module Az.Compute

$connectionName = "AzureRunAsConnection"

    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 


# Stop an existing firewall

$azfw = Get-AzFirewall -Name $AzureFirewall -ResourceGroupName $AzureFirewallResourceGroup
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw