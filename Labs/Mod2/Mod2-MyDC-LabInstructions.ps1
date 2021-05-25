$servers = @('S2D1','S2D2','S2D3','S2D4')
$features = 'Hyper-V', 'Failover-Clustering', 'Data-Center-Bridging', 'RSAT-Clustering-PowerShell', 'Hyper-V-PowerShell', 'FS-FileServer'
Invoke-Command ($servers) {
 Install-WindowsFeature -Name $using:features
 }

Invoke-Command ($servers) {
  Restart-Computer -Force
  }

Invoke-Command ($servers) {
 Update-StorageProviderCache
  Get-StoragePool | ? IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false -ErrorAction SilentlyContinue
  Get-StoragePool | ? IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false -ErrorAction SilentlyContinue
  Get-StoragePool | ? IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false -ErrorAction SilentlyContinue
  Get-PhysicalDisk | Reset-PhysicalDisk -ErrorAction SilentlyContinue
  Get-Disk | ? Number -ne $null | ? IsBoot -ne $true | ? IsSystem -ne $true | ? PartitionStyle -ne RAW | % {
      $_ | Set-Disk -isoffline:$false
      $_ | Set-Disk -isreadonly:$false
      $_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
      $_ | Set-Disk -isreadonly:$true
      $_ | Set-Disk -isoffline:$true
  }
  Get-Disk | Where Number -Ne $Null | Where IsBoot -Ne $True | Where IsSystem -Ne $True | Where PartitionStyle -Eq RAW | Group -NoElement -Property FriendlyName
  } | Sort -Property PsComputerName, Count


Test-Cluster -Node 'S2D1','S2D2','S2D3','S2D4' -Include 'Storage Spaces Direct', 'Inventory', 'Network', 'System Configuration'

New-Cluster -Name 'S2DCL1' -Node 'S2D1','S2D2','S2D3','S2D4' -NoStorage


# Task 4:

Enable-ClusterStorageSpacesDirect -CimSession 'S2DCL1'


# Task 5 (!Run these in Azure PowerShell Cli!):
Register-AzResourceProvider -ProviderNamespace Microsoft.Insights  
Register-AzResourceProvider -ProviderNamespace Microsoft.AlertsManagement

Get-AzResourceProvider -ProviderNamespace Microsoft.Insights  
Get-AzResourceProvider -ProviderNamespace Microsoft.AlertsManagement

