# Mod 3
# Management VM
# Lab 3E
# Ex 1
# Task 3
Install-WindowsFeature -Name RSAT-Clustering,RSAT-Clustering-Mgmt,RSAT-Clustering-PowerShell,RSAT-Hyper-V-Tools,RSAT-AD-PowerShell,RSAT-ADDS

# Install chrome:
$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

# Install WAC:
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v waclog.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"


# Step 7
$gateway = "Management"
$nodes = Get-ADComputer -Filter * -SearchBase "ou=workshop,DC=corp,dc=contoso,DC=com"
$gatewayObject = Get-ADComputer -Identity $gateway
    foreach ($node in $nodes){
Set-ADComputer -Identity $node -PrincipalsAllowedToDelegateToAccount $gatewayObject
}


# Task 3:
# Step 1:
$clusters=@()
$clusters+=@{Nodes=1..2 | % {"2T2node$_"} ; Name="2T2nodeClus" ; IP="10.0.0.112" }
$clusters+=@{Nodes=1..3 | % {"2T3node$_"} ; Name="2T3nodeClus" ; IP="10.0.0.113" }
$clusters+=@{Nodes=1..2 | % {"3T2node$_"} ; Name="3T2nodeClus" ; IP="10.0.0.115" }
$clusters+=@{Nodes=1..3 | % {"3T3node$_"} ; Name="3T3nodeClus" ; IP="10.0.0.116" }

# Install features on servers
Invoke-Command -computername $clusters.nodes -ScriptBlock {
 Install-WindowsFeature -Name "Failover-Clustering","Hyper-V-PowerShell","RSAT-Clustering-PowerShell" #RSAT is needed for Windows Admin Center
}

# Restart servers since failover clustering in Windows Server 2019 requires reboot
Restart-Computer -ComputerName $clusters.nodes -Protocol WSMan -Wait -For PowerShell

# Create clusters
foreach ($cluster in $clusters){
 New-Cluster -Name $cluster.Name -Node $cluster.Nodes -StaticAddress $cluster.IP
 Start-Sleep 5
 Clear-DNSClientCache
}

# Add file share witness
foreach ($cluster in $clusters){
 $clusterName = $cluster.Name
 # Create new directory
 $WitnessName = $clusterName+"Witness"
 Invoke-Command -ComputerName DC -ScriptBlock {New-Item -Path c:\Shares -Name $using:WitnessName -ItemType Directory}
 $accounts = @()
 $accounts += "CORP\$($clusterName)$"
 $accounts += "CORP\Domain Admins"
 New-SmbShare -Name $WitnessName -Path "c:\Shares\$WitnessName" -FullAccess $accounts -CimSession DC
 # Set NTFS permissions
 Invoke-Command -ComputerName DC -ScriptBlock {(Get-SmbShare $using:WitnessName).PresetPathAcl | Set-Acl}
 # Set Quorum
 Set-ClusterQuorum -Cluster $clusterName -FileShareWitness "\\DC\$WitnessName"
}

# Enable Storage Spaces Direct and configure mediatype to simulate 3 tier system with SCM (all 800GB disks are SCM, all 4T are SSDs)
foreach ($cluster in $clusters.Name){
 Enable-ClusterS2D -CimSession $cluster -Verbose -Confirm:0
 if ($cluster -like "3T*"){
    invoke-command -computername $cluster -scriptblock {
    Get-PhysicalDisk | Where-Object size -eq 800GB | Set-PhysicalDisk -MediaType SCM
    Get-PhysicalDisk | Where-Object size -eq 4TB | Set-PhysicalDisk -MediaType SSD
   }
 }
}

# Step 2
(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1).Name | Out-File c:\s2dclusters.txt
PSEdit c:\s2dclusters.txt 

# Step 3
Start-process  https://management.corp.contoso.com

# Task 4:
# Step 1:
Get-StorageTier -CimSession 2T2NodeClus |
 ft FriendlyName,MediaType,ResiliencySettingName,NumberOfDataCopies,PhysicalDiskRedundancy,FaultDomainAwareness,ColumnIsolation,NumberOfGroups,NumberOfColumns

# Step 2:
$clusters=(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1).Name
Get-StorageTier -CimSession $clusters |
    Sort-Object PSComputerName |
    ft PSComputerName,FriendlyName,MediaType,ResiliencySettingName,NumberOfDataCopies,PhysicalDiskRedundancy,FaultDomainAwareness,ColumnIsolation,NumberOfGroups,NumberOfColumns


# Step 3:
$clusters=(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1).Name
Get-StorageTier -CimSession $clusters |
    Where-Object friendlyname -like mirror* |
    Sort-Object PSComputerName |
    ft PSComputerName,FriendlyName,MediaType,ResiliencySettingName,NumberOfDataCeness,ColsicalDiskRedundancy,FaultDomainAwareness,ColumnIsolation,NumberOfGroups,NumberOfColumns

# Step 4:
$clusters=(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1).Name
Get-StorageTier -CimSession $clusters |
    Where-Object friendlyname -like parity* |
    Sort-Object PSComputerName |
    ft PSComputerName,FriendlyName,MediaType,ResiliencySettingName,NumberOfDataCopies,PhysicalDiskRedundancy,FaultDomainAwareness,ColumnIsolation,NumberOfGroups,NumberOfColumns

# Step 5:
# Select clusters to fix tiers:
# Note: When prompted, in the Select Clusters to Check on tiers window, select the Ctrl key, 
# select both the 2T2nodeClus and 3T2nodeClus entry, and then select OK. 
$clusterNames=(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1 | Out-GridView -OutputMode Multiple -Title "Select Clusters to Check on tiers").Name

foreach ($clusterName in $clusterNames){
$storageTiers=Get-StorageTier -CimSession $clusterName
$numberOfNodes=(Get-ClusterNode -Cluster $clusterName).Count
$MediaTypes=(Get-PhysicalDisk -CimSession $clusterName |where mediatype -ne Unspecified | Where-Object usage -ne Journal).MediaType | Select-Object -Unique
$clusterFunctionalLevel=(Get-Cluster -Name $clusterName).ClusterFunctionalLevel

foreach ($mediaType in $mediaTypes){
if ($numberOfNodes -eq 2) {
# Create Mirror Tiers
if (-not ($storageTiers | Where-Object FriendlyName -eq "MirrorOn$mediaType")){
New-StorageTier -CimSession $clusterName -StoragePoolFriendlyName "S2D on $clusterName" -FriendlyName "MirrorOn$mediaType" -MediaType $mediaType -ResiliencySettingName Mirror -NumberOfDataCopies 2
}
if ($clusterFunctionalLevel -ge 10){
# Create NestedMirror Tiers
if (-not ($storageTiers | Where-Object FriendlyName -eq "NestedMirrorOn$mediaType")){
New-StorageTier -CimSession $clusterName -StoragePoolFriendlyName "S2D on $clusterName" -FriendlyName "NestedMirrorOn$mediaType" -MediaType $mediaType -ResiliencySettingName Mirror -NumberOfDataCopies 4
}
#Create NestedParity Tiers
if (-not ($storageTiers | Where-Object FriendlyName -eq "NestedParityOn$mediaType")){
New-StorageTier -CimSession $clusterName -StoragePoolFriendlyName "S2D on $clusterName" -FriendlyName "NestedParityOn$mediaType" -MediaType $mediaType -ResiliencySettingName Parity -NumberOfDataCopies 2 -PhysicalDiskRedundancy 1 -NumberOfGroups 1 -ColumnIsolation PhysicalDisk
}
}
}
}
}

# Step 6:
$clusters=(Get-Cluster -Domain $env:userdomain | Where-Object S2DEnabled -eq 1).Name
Get-StorageTier -CimSession $clusters |
    Where-Object friendlyname -like nested* |
    Sort-Object PSComputerName |
    ft PSComputerName,FriendlyName,MediaType,ResiliencySettingName,NumberOfDataCopies,PhysicalDiskRedundancy,FaultDomainAwareness,ColumnIsolation,NumberOfGroups,NumberOfColumns


# Task 5: 
# Step 1:
$clusterName = '2T2nodeClus'
New-Volume -StoragePoolFriendlyName s2d* -FriendlyName NestedMirroronHDDVolume -FileSystem CSVFS_ReFS -StorageTierFriendlyNames NestedMirrorOnHDD -StorageTierSizes 128GB -CimSession $clusterName

# Step 9:
$clusterName = '3T2nodeClus'
New-Volume -StoragePoolFriendlyName s2d* -FriendlyName NestedMirroronSSDVolume -FileSystem CSVFS_ReFS -StorageTierFriendlyNames NestedMirrorOnSSD -StorageTierSizes 128GB -CimSession $clusterName





