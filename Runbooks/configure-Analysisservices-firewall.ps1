### script to dynamically configure Analysis services firewall based on client public IP

$mypublicip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
$analysisservicesserver = Read-Host "please specify the Puma Analysis Services Server you want to access"
Add-AzAnalysisServicesAccount -RolloutEnvironment $analysisservicesenvironment
$firewallrule = New-AzAnalysisServicesFirewallRule -FirewallRuleName "client$mypublic" -RangeStart $mypublicip -RangeEnd $mypublicip
$firewallruleconfig = New-AzAnalysisServicesFirewallConfig -FirewallRule $firewallrule
Set-AzAnalysisServicesServer -Name $analysisservicesserver -FirewallConfig $firewallruleconfig




