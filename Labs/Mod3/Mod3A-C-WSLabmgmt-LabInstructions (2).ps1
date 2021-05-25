# Lab A
# Ex 1

Install-WindowsFeature -Name RSAT-Clustering,RSAT-Clustering-Mgmt,RSAT-Clustering-PowerShell,RSAT-Hyper-V-Tools,RSAT-AD-PowerShell,RSAT-ADDS

$gateway = "Management"
$nodes = Get-ADComputer -Filter * -SearchBase "ou=workshop,DC=corp,dc=contoso,DC=com"
$gatewayObject = Get-ADComputer -Identity $gateway
foreach ($node in $nodes){
Set-ADComputer -Identity $node -PrincipalsAllowedToDelegateToAccount $gatewayObject
}

$servers = @('S2D1','S2D2','S2D3','S2D4')
Enable-WSMANCredSSP -Role client -DelegateComputer $servers -Force


$servers = @('S2D1','S2D2','S2D3','S2D4')
Invoke-Command -ComputerName $servers -ScriptBlock {Enable-WSMANCredSSP -Role server -Force}


# Task 6
# Step 10
$clusterName = 'S2D-Cluster'
$witnessName = $clusterName + "Witness"
Invoke-Command -ComputerName DC -ScriptBlock {New-Item -Path c:\Shares -Name $using:witnessName -ItemType Directory}
$accounts = @()
$accounts += "CORP\$($clusterName)$"
$accounts += 'CORP\Domain Admins'
New-SmbShare -Name $WitnessName -Path "c:\Shares\$witnessName" -FullAccess $accounts -CimSession DC -ErrorAction SilentlyContinue
Invoke-Command -ComputerName DC -ScriptBlock {(Get-SmbShare $using:witnessName).PresetPathAcl | Set-Acl}
# Set Quorum
Set-ClusterQuorum -Cluster $clusterName -FileShareWitness "\\DC\$witnessName"

