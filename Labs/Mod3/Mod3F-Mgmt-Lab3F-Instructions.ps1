# Lab F: Identifying and analyzing metadata of a Storage Spaces Direct cluster (optional)

#Exercise 1: Identifying and analyzing metadata of a Storage Spaces Direct cluster
<# Scenario

To ensure that you understand resiliency provisions that must be taken into account to protect cluster stability and integrity, and to be able to identify how the Storage Spaces Direct cluster maintains information about its data, you need to identify and analyze the metadata of the storage pool and its components.

The main tasks for this exercise are as follows:

Deploy a Storage Spaces Direct cluster.
Examine physical disk owners.
Explore storage pool metadata.
Explore metadata of a volume.
Explore metadata of a scoped volume.
Deprovision the lab resources.
# Task 2: Deploy a Storage Spaces Direct cluster
In the lab environment switch to WSLab-Management and send the CTRL+ALT+DEL command. When prompted to sign in, provide the CORP\LabAdmin username and LS1setup! password.
#>

# In the console session to the WSLab-Management VM, start Windows PowerShell ISE as Administrator.
# In the console session to the WSLab-Management VM, from the script pane of the Administrator: Windows PowerShell ISE window, run the following command to provision a six-node Storage Spaces Direct cluster:
$clusters = @()
$clusters += @{Nodes=1..6 | % {"6node$_"} ; Name="6nodeCluster" ; IP="10.0.0.116" }

Install-WindowsFeature -Name RSAT-Clustering,RSAT-Clustering-Mgmt,RSAT-Clustering-PowerShell,RSAT-Hyper-V-Tools,RSAT-AD-PowerShell, RSAT-ADDS

# Install features on servers
Invoke-Command -computername $clusters.nodes -ScriptBlock {
  Install-WindowsFeature -Name "Failover-Clustering","Hyper-V-PowerShell"
}

# Restart all servers to finalize installation of Failover Clustering
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
  $witnessName = $clusterName+"Witness"
  Invoke-Command -ComputerName DC -ScriptBlock {New-Item -Path c:\Shares -Name $using:witnessName -ItemType Directory}
  $accounts = @()
  $accounts += "CORP\$($clusterName)$"
  $accounts += "CORP\Domain Admins"
  New-SmbShare -Name $witnessName -Path "c:\Shares\$witnessName" -FullAccess $accounts -CimSession DC
  # Set NTFS permissions
  Invoke-Command -ComputerName DC -ScriptBlock {(Get-SmbShare $using:witnessName).PresetPathAcl | Set-Acl}
  # Set Quorum
  Set-ClusterQuorum -Cluster $clusterName -FileShareWitness "\\DC\$WitnessName"
}

# Enable S2D
Enable-ClusterS2D -CimSession $clusters.Name -Verbose -Confirm:0
# Note: Wait for the script to complete. This should take about five minutes.


# Task 3: Examine physical disk owners
# In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, run the following command to display the physical disks of the 6nodecluster Storage Spaces Direct cluster:

Get-PhysicalDisk -CimSession 6nodecluster |ft FriendlyName,Size,Description
# In the console session to the WSLab-Management VM, from the script pane of the Administrator: Windows PowerShell ISE window, run the following command to set the Description attribute of each physical disk to the name of the cluster node to which the disk is attached for the Storage Spaces Direct cluster:

$clusters = @()
$clusters += @{Nodes=1..6 | % {"6node$_"} ; Name="6nodeCluster" ; IP="10.0.0.116" }
foreach ($clusterName in ($clusters.Name | select -Unique)){
  $storageNodes=Get-StorageSubSystem -CimSession $clusterName -FriendlyName Clus* | Get-StorageNode
  foreach ($storageNode in $storageNodes){$storageNode | Get-PhysicalDisk -PhysicallyConnected -CimSession $storageNode.Name | Set-PhysicalDisk -Description $storageNode.Name -CimSession $storageNode.Name}
}
# In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, rerun the following command to display physical disks of 6nodecluster Storage Spaces Direct cluster, this time with the Description attribute containing the name of the owner node:

Get-PhysicalDisk -CimSession 6nodecluster |ft FriendlyName,Size,Description
# Task 4: Explore metadata of the storage pool
# In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, run the following command to display the number of disks with metadata for the six-node cluster:
foreach ($clusterName in ($clusters.Name | select -Unique)){
 Get-StoragePool -CimSession $clusterName |
 Get-PhysicalDisk -HasMetadata -CimSession $clusterName |
 Sort-Object Description |
 Format-Table DeviceId,FriendlyName,SerialNumber,MediaType,Description
}
# Note: The number of disks with metadata depends on the size of the cluster, as the following table displays:

<# Table 1: The number of disks with metadata
Number of nodes (fault domains)	Number of disks with metadata
2	6
3	6
4	8
5	5
6	5
In the console session to the WSLab-Management VM, switch to the Server Manager window, select Tools, and then in the Tools drop-down list, select Failover Cluster Manager.
In the Failover Cluster Manager window, right-click or access the context menu for the Failover Cluster Manager node, and then in the context menu, select Connect to cluster.
In the Select Cluster dialog box, in the Cluster name text box, enter 6nodecluster.corp.contoso.com, and then select OK.
In the Failover Cluster Manager window, select Nodes, and then review the list of nodes.
In the Failover Cluster Manager window, in the Storage node tree, select Pools, and then verify that it contains a single pool named Cluster Pool 1.
Select the Cluster Pool 1 entry, and on the Cluster Pool 1 pane, examine its properties by selecting the Summary tab, followed by the Virtual Disks and Physical Disks tabs.
#>

# In the console session to the WSLab-Management VM, switch to the Administrator: Windows PowerShell ISE window, and then from the script pane, run the following command to capture the list of three nodes hosting the storage pool metadata of the six-node cluster:
$nodesToShutDown = (Get-StoragePool -CimSession 6nodecluster |
Get-PhysicalDisk -HasMetadata -CimSession $clusterName | Select-Object -First 3).Description

# In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, run the following command to shut down the three nodes hosting the metadata of the six-node cluster:
Stop-Computer -ComputerName $nodesToShutDown -Force

# In the console session to the WSLab-Management VM, switch to the Failover Cluster Manager window, and then in the Storage node tree, with the Pools node selected, verify that the Cluster Pool 1 storage pool has a status of Failed.
# Note: It might take a few minutes before the storage pool reaches the Failed status.

<# In the Failover Cluster Manager window, on the Actions pane, select Show Critical Events, and in the list of events, locate the most recent event that references the storage pool failure because of the lack of quorum of healthy disks.
In the Critical events for Cluster Pool 1 window, review the event, and then select Close.
Switch to the lab VM, and then in the Hyper-V Manager console, in the list of virtual machines, select the VM you shut down earlier in this task, and then in the Actions pane, in the Selected Virtual Machines section, select Start.
Switch to the WSLab-Management VM, in the Failover Cluster Manager window, right-click or access the context menu for the Cluster Pool 1 entry, and in the context menu, select Bring Online.
#>

# Task 5: Explore metadata of a volume
# In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, run the following command to create a volume on the six-node cluster:
Invoke-Command -ComputerName ($clusters.Name | select -Unique) -ScriptBlock {New-Volume -FriendlyName labVolume -Size 100GB}

#In the console session to the WSLab-Management VM, from the console pane of the Administrator: Windows PowerShell ISE window, run the following command to display the metadata of the newly created volume on the six-node cluster:
foreach ($clusterName in ($clusters.Name | select -Unique)){
  Get-VirtualDisk -FriendlyName labVolume -CimSession $clusterName |
  Get-PhysicalDisk -HasMetadata -CimSession $clusterName |
  Sort-Object Description |
  Format-table DeviceId,FriendlyName,SerialNumber,MediaType,Description
}
# Note: Based on the output, you can determine whether the number of disks with metadata matches the number of disks used by the storage pool metadata.

# Task 6: Explore metadata of a scoped volume
# In the console session to the WSLab-Management VM, from the script pane of the Administrator: Windows PowerShell ISE window, run the following command to create scoped volumes on the six-node cluster:
$faultDomains = Get-StorageFaultDomain -Type StorageScaleUnit -CimSession 6nodecluster | Sort FriendlyName
New-Volume -FriendlyName "2Scope-Volume" -Size 100GB -StorageFaultDomainsToUse ($faultDomains | Get-Random -Count 2) -CimSession 6nodecluster -StoragePoolFriendlyName S2D* -NumberOfDataCopies 2
New-Volume -FriendlyName "3Scope-Volume" -Size 100GB -StorageFaultDomainsToUse ($faultDomains | Get-Random -Count 3) -CimSession 6nodecluster -StoragePoolFriendlyName S2D*
New-Volume -FriendlyName "4Scope-Volume" -Size 100GB -StorageFaultDomainsToUse ($faultDomains | Get-Random -Count 4) -CimSession 6nodecluster -StoragePoolFriendlyName S2D*
New-Volume -FriendlyName "5Scope-Volume" -Size 100GB -StorageFaultDomainsToUse ($faultDomains | Get-Random -Count 5) -CimSession 6nodecluster -StoragePoolFriendlyName S2D*
New-Volume -FriendlyName "6Scope-Volume" -Size 100GB -StorageFaultDomainsToUse ($faultDomains | Get-Random -Count 6) -CimSession 6nodecluster -StoragePoolFriendlyName S2D*
Note: For a six-node cluster, set the number of a volume's scopes to four. The additional volumes in this exercise aren't used as an example of their practical use, but rather as an illustration about how different scope values affect volume distribution.

# In the console session to the WSLab-Management VM, from the script pane of the Administrator: Windows PowerShell ISE window, run the following command to display the metadata of the newly created volumes on the six-node cluster:
$friendlyNames=2..6 | % {"$($_)Scope-Volume"}
foreach ($friendlyName in $friendlyNames){
  Write-Host -Object "$friendlyName" -ForeGroundColor Cyan
  Get-VirtualDisk -FriendlyName $friendlyName -CimSession 6nodecluster |
  Get-PhysicalDisk -HasMetadata -CimSession 6nodecluster |
  Sort-Object Description |
  Format-Table DeviceId,FriendlyName,SerialNumber,MediaType,Description
}

