parameter(Mandatory=$false)]
[string] $environmentName = "AzureCloud",   
 
[parameter(Mandatory=$false)]
[string] $resourceGroupName,
 
[parameter(Mandatory=$false)]
[string] $azureRunAsConnectionName = "AzureRunAsConnection",
 
[parameter(Mandatory=$true)]
[string] $SubscriptionID,
 
[parameter(Mandatory=$true)]
[string] $PolicyassignmentID,

[parameter(Mandatory=$true)]
[string] $RemediationName = New-Guid
 
 
[parameter(Mandatory=$false)]
[string] $scalingScheduleTimeZone = "W. Europe Standard Time",
 

 
filter timestamp {"[$(Get-Date -Format G)]: $_"}
 
Write-Output "Script started." | timestamp
 
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"
 
# #Authenticate with Azure Automation Run As account (service principal)
# $runAsConnectionProfile = Get-AutomationConnection -Name $azureRunAsConnectionName
# $environment = Get-AzureRmEnvironment -Name $environmentName
# Add-AzureRmAccount -Environment $environment -ServicePrincipal `
# -TenantId $runAsConnectionProfile.TenantId `
# -ApplicationId $runAsConnectionProfile.ApplicationId `
# -CertificateThumbprint ` $runAsConnectionProfile.CertificateThumbprint | Out-Null
# Write-Output "Authenticated with Automation Run As Account."  | timestamp
 

#Perform Policy remedation for the subscriptions
$subscriptionname = (Get-AzSubscription -SubscriptionId $SubscriptionID).name

$policyidtemp = "/subscriptions/9076d78f-8a52-4f8d-8567-11b42296bf31/resourceGroups/RG-TerraformConfig/providers/Microsoft.Authorization/policyAssignments/870305efe539470998364b8b"

Select-AzSubscription -Subscription $subscriptionname

Write-Host -ForegroundColor green "Performing Policy Remediation for Subscription $subscriptionname"

Start-AzPolicyRemediation -Name $RemediationName -PolicyAssignmentId $policyidtemp -Scope "/subscriptions/9076d78f-8a52-4f8d-8567-11b42296bf31/resourceGroups/RG-TerraformConfig" -ResourceDiscoveryMode ReEvaluateCompliance
$RemediationTask = Get-AzPolicyRemediation -Name $RemediationName
$Remediationtaskname = $RemediationTask.Name
$PolicyAssignmentObject = Get-AzPolicyAssignment -Id $policyidtemp
$PolicyAssignmentname = $PolicyAssignmentObject.Name

while ($Remediationtask.ProvisioningState -eq "Accepted") 
{
    Write-Host -ForegroundColor Blue "Policy Remediation in progress...."    
}


if ($Remediationtask.ProvisioningState -eq "Failed")
{
    Write-Host -ForegroundColor Red "Remediaton Task $remediationtaskname for PolicyAssignment $PolicyAssignmentname failed"
}
elseif ($Remediationtask.ProvisioningState -eq "Succeeded") 
{
    Write-Host -ForegroundColor green "Remediaton Task $remediationtaskname for PolicyAssignment $PolicyAssignmentname was successful"
}
else {
    Write-Host -ForegroundColor yellow "Unknown state of Remediaton Task $remediationtaskname for PolicyAssignment $PolicyAssignmentname"
}


